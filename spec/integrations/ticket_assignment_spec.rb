require 'rails_helper'

RSpec.describe "Gtag assignment ", type: :feature do
  let(:event) { create(:event, state: "created") }
  let(:customer) { create(:customer, email: "test@customer.com", event: event, anonymous: false) }
  let(:ticket) { create(:ticket, event: event) }

  before do
    login_as(customer, scope: :customer)
    visit new_event_ticket_assignment_path(event)
  end

  it "can activate a valid ticket" do
    within("#new_ticket") { fill_in 'ticket_reference', with: ticket.reference }

    expect { find("input[name=commit]").click }.to change(customer.tickets, :count).by(1)
    expect(page).to have_current_path(customer_root_path(event))
  end

  it "can't activate an invalid ticket" do
    within("#new_ticket") { fill_in 'ticket_reference', with: "R4ND0M" }

    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end

  it "can't activate a banned ticket" do
    ticket.update! banned: true
    within("#new_ticket") { fill_in 'ticket_reference', with: ticket.reference }

    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end

  it "can't activate already assigned ticket" do
    ticket.update! customer: create(:customer, event: event, anonymous: false)
    within("#new_ticket") { fill_in 'ticket_reference', with: ticket.reference }

    expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    expect(page).to have_current_path(event_ticket_assignments_path(event))
  end
end
