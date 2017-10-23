require 'rails_helper'

RSpec.describe "Create an online order", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event) }

  before do
    @ticket = create(:ticket, event: event)
    @gtag = create(:gtag, event: event)
    @catalog_item = create(:catalog_item, event: event)
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
  end

  it "is in right location " do
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "is located in ticket_assignments/new and can activate a ticket" do
    find_link("add_new_ticket_link").click
    expect(page).to have_current_path(new_event_ticket_assignment_path(event))

    expect do
      within("#new_ticket") do
        fill_in 'ticket_reference', with: @ticket.code
      end
      find("input[name=commit]").click
    end.to change(customer.tickets, :count).by(1)

    expect(page).to have_current_path(customer_root_path(event))
  end

  it "is located in gtag_assignment/new and can activate a gtag" do
    find_link("add_new_gtag_link").click
    expect(page).to have_current_path(new_event_gtag_assignment_path(event))

    expect do
      within("#new_gtag") do
        fill_in 'gtag_reference', with: @gtag.tag_uid
      end
      find("input[name=commit]").click
    end.to change(customer.gtags, :count).by(1)

    expect(page).to have_current_path(customer_root_path(event))
  end

  it "is building order with credis" do
    order = customer.build_order([[event.credit.id, 5]])
    order.complete!

    expect(customer.global_credits).to eq(5.to_f)
  end

  it "is building order with catalog item" do
    order = customer.build_order([[@catalog_item.id, 1]])
    order.complete!

    expect(order.order_items.map(&:catalog_item)).to include(@catalog_item)
  end
end
