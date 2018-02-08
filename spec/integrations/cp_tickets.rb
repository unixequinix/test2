require 'rails_helper'

RSpec.describe "Tickets in customer portal", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:customer) { create(:customer, event: event) }
  let!(:ticket) { create(:ticket, event: event, customer: customer) }
  let!(:new_ticket) { create(:ticket, event: event) }
  before(:each) do
    login_as(customer, scope: :customer)
    visit customer_root_path(event)
  end

  describe "add ticket" do
    before(:each) { click_link("add_new_ticket_link") }

    it "correctly" do
      within("#new_ticket") { fill_in 'ticket_reference', with: new_ticket.code }
      expect { find("input[name=commit]").click }.to change(customer.tickets, :count).by(1)
    end

    it "non-existent" do
      within("#new_ticket") { fill_in 'ticket_reference', with: "12345" }
      expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    end

    it "previously assigned" do
      within("#new_ticket") { fill_in 'ticket_reference', with: ticket.code }
      expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    end

    it "same content ticket" do
      new_ticket.update ticket_type: ticket.ticket_type
      within("#new_ticket") { fill_in 'ticket_reference', with: new_ticket.code }
      expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    end

    it "banned" do
      new_ticket.update banned: true
      within("#new_ticket") { fill_in 'ticket_reference', with: new_ticket.code }
      expect { find("input[name=commit]").click }.not_to change(customer.tickets, :count)
    end
  end

  it "select a ticket" do
    click_link(ticket.id.to_s)
    expect(page).to have_current_path(event_ticket_path(event, ticket))
  end

  it "unassign ticket" do
    visit event_ticket_path(event, ticket)
    expect { click_link("unassign_ticket") }.to change(customer.tickets, :count).by(-1)
  end
end
