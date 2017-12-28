require 'rails_helper'

RSpec.describe "Tickets in the admin panel", type: :feature do
  let(:event) { create(:event, name: "EventoTickets", state: "launched") }
  let(:user) { create(:user, role: "admin") }
  let!(:ticket) { create(:ticket, code: "Ticket1", event: event) }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "create: " do
    before { visit new_admins_event_ticket_path(event) }

    it "cannot be created by only filling Ticket Type" do
      expect { find("input[name=commit]").click }.not_to change(Ticket, :count)
    end

    it "cannot have the same Ticket Code than another ticket" do
      fill_in 'ticket_code', with: "Ticket1"
      expect { find("input[name=commit]").click }.not_to change(Ticket, :count)
    end

    it "can be created by filling Ticket Type and code" do
      fill_in 'ticket_code', with: "Ticket3"
      first('#ticket_ticket_type_id option', minimum: 1).select_option
      expect { find("input[name=commit]").click }.to change(Ticket, :count).by(1)
    end

    it "can be created by filling all fields" do
      fill_in 'ticket_code', with: "Ticket3"
      first('#ticket_ticket_type_id option', minimum: 1).select_option
      fill_in 'ticket_purchaser_first_name', with: "PurchaserName"
      fill_in 'ticket_purchaser_last_name', with: "PurchaserSurname"
      fill_in 'ticket_purchaser_email', with: "Purchaser@email.com"
      expect { find("input[name=commit]").click }.to change(Ticket, :count).by(1)
    end
  end

  describe "edit: " do
    before { visit edit_admins_event_ticket_path(event, ticket) }

    it "can edit a Ticket" do
      fill_in 'ticket_code', with: "1234567890"
      expect { find("input[name=commit]").click }.to change { ticket.reload.code }.to("1234567890")
    end

    it "cannot edit a Ticket and leave it without Ticket Code" do
      fill_in 'ticket_code', with: ""
      expect { find("input[name=commit]").click }.not_to change { ticket.reload.code }.from(ticket.code)
    end
  end

  describe "delete: " do
    before { visit admins_event_ticket_path(event, ticket) }

    it "can be achieved if event is in 'created' state" do
      event.update! state: "created"
      expect { click_link("delete") }.to change(Ticket, :count).by(-1)
    end

    it "cannot be achieved if event is in 'launched' state" do
      event.update! state: "launched"
      expect { click_link("delete") }.not_to change(Ticket, :count)
    end

    it "cannot be achieved if event is in 'close' state" do
      event.update! state: "closed"
      expect { click_link("delete") }.not_to change(Ticket, :count)
    end
  end
end
