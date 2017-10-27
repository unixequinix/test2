require 'rails_helper'

RSpec.describe "Ticket assingment", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:ticket) { create(:ticket, event: event) }
  let(:banned_ticket) { create(:ticket, event: event, banned: true) }

  before do
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
    find_link("add_new_ticket_link").click
    expect(page).to have_current_path(new_event_ticket_assignment_path(event))
  end

  it "can activate a ticket" do
    within("#new_ticket") { fill_in 'ticket_reference', with: ticket.code }
    expect { find("input[name=commit]").click }.to change(customer.tickets, :count).by(1)

    expect(page).to have_current_path(customer_root_path(event))
  end

  it "can't activate an invalid ticket" do
    within("#new_ticket") { fill_in 'ticket_reference', with: "R4ND0M" }
    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)

    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end

  it "can't activate a banned ticket" do
    within("#new_ticket") { fill_in 'ticket_reference', with: banned_ticket.code }
    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)

    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end

  it "can't activate already assigned ticket" do
    create(:customer, event: event, anonymous: false)
    create(:ticket, event: event, customer: event.customers.last)
    within("#new_ticket") { fill_in 'ticket_reference', with: event.tickets.last.code }
    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)

    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end
end
