require 'rails_helper'

RSpec.describe "Create an online order", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }

  before do
    @ticket = create(:ticket, event: event, customer: customer)
    @gtag = create(:gtag, event: event)
    @catalog_item = create(:catalog_item, event: event)
    @item_crd = event.catalog_items.find_by(name: "CRD")
    @station = create(:station, event: event)
    @station_catalog_item_crd = create(:station_catalog_item, station: @station, catalog_item: @item_crd, price: 1.0)
    @station_catalog_item = create(:station_catalog_item, station: @station, catalog_item: @catalog_item, price: 0.0)
    create(:payment_gateway, event: event, topup: true, name: "paypal", login: "test.glownet.com", password: "test", signature: "test")
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
  end

  it "is in right location " do
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "is located in ticket_assignments/new and can activate a ticket" do
    find_link("add_new_ticket_link").click
    expect(page).to have_current_path(new_event_ticket_assignment_path(event))
    ticket = create(:ticket, event: event)
    expect do
      within("#new_ticket") do
        fill_in 'ticket_reference', with: ticket.code
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

  it "is located in orders/new and topup with credits" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))
    expect do
      within("#checkout-form") do
        fill_in 'input-range', with: 50
      end

      find("button[name=commit]").click
      @order = event.orders.last
      expect(page).to have_current_path(event_order_path(event, @order))
      @order.complete!
      expect(@order.order_items.map(&:catalog_item)).to include @item_crd
    end.to change(customer, :global_credits)
  end

  it "is located in orders/new and buy items with total of 0" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))

    within("#checkout-form") do
      fill_in 'input-range', with: 0
      all("#amount-input-#{@catalog_item.id} option")[1].select_option
    end

    find("button[name=commit]").click
    @order = event.orders.last
    expect(page).to have_current_path(event_order_path(event, @order))
    @order.complete!
    expect(@order.order_items.map(&:catalog_item)).to include @catalog_item
  end

  it "is located in orders/new and buy items with total greater than 0" do
    find_link("new_top_up").click
    expect(page).to have_current_path(new_event_order_path(event))

    within("#checkout-form") do
      fill_in 'input-range', with: 50
      all("#amount-input-#{@catalog_item.id} option")[1].select_option
    end

    find("button[name=commit]").click
    @order = event.orders.last
    expect(page).to have_current_path(event_order_path(event, @order))
    @order.complete!
    expect(@order.order_items.map(&:catalog_item)).to include @catalog_item
  end
end
