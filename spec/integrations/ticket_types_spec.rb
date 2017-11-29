require 'rails_helper'

RSpec.describe "Creating a ticket type", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }
  let!(:company) { create(:company, event: event) }

  before { login_as(user, scope: :user) }

  describe "create:" do
    before { visit new_admins_event_ticket_type_path(event) }

    it "must contain name and company" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME" }
      find("#ticket_type_company_id").select(company.name)

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(page).to have_current_path admins_event_ticket_types_path(event)
      expect(TicketType.last.name).to eql("TESTTICKETTYPENAME")
      expect(TicketType.last.company).to eql(company)
    end

    it "can't be done without a name" do
      within("#new_ticket_type") { first('#ticket_type_company_id option').select_option }

      expect { find("input[name=commit]").click }.not_to change(TicketType, :count)
    end

    it "allows to assign a catalog_item" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME" }

      find("#ticket_type_company_id").select(company.name)
      find("#ticket_type_catalog_item_id").select(event.credit.name)

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(TicketType.last.catalog_item).to eql(event.credit)
    end

    it "allows to assign a company_code" do
      within("#new_ticket_type") do
        fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME"
        fill_in 'ticket_type_company_code', with: "TEST"
      end

      find("#ticket_type_company_id").select(company.name)

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(TicketType.last.company_code).to eql("TEST")
    end
  end


  describe "delete:" do
    let(:ticket_type) { create(:ticket_type, event: event)}

    before { visit admins_event_ticket_type_path(event, ticket_type) }

    it "can be done only if event state is created" do
      event.update! state: "created"
      expect { find("#delete_ticket_type").click }.to change { event.reload.ticket_types.count }.by(-1)
    end

    it "cannot be done if state is not 'created'" do
      event.update! state: "closed"
      expect { find("#delete_ticket_type").click }.not_to change(event.reload.ticket_types, :count)
    end

    it "deletes all tickets within the ticket type" do
      event.update! state: "created"
      create_list(:ticket, 3, event: event, ticket_type: ticket_type)
      expect { find("#delete_ticket_type").click }.to change { event.reload.tickets.count }.by(-3)

    end
  end
end

