require 'rails_helper'

RSpec.describe "Tests on ticket type view", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }
  let!(:company) { create(:company, event: event) }
  let(:catalog_item) { create(:catalog_item, event: event) }
  let!(:ticket_type) { create(:ticket_type, event: event, catalog_item: catalog_item, name: "Friday") }
  let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }

  before do
    login_as(user, scope: :user)
    visit admins_event_ticket_types_path(event)
  end

  describe "create:" do
    before { click_link("new_ticket_type") }

    it "with name and company" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME" }
      find("#ticket_type_company_id").select(company.name)

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(page).to have_current_path admins_event_ticket_types_path(event)
      expect(TicketType.last.name).to eql("TESTTICKETTYPENAME")
      expect(TicketType.last.company).to eql(company)
    end

    it "cannot without a name" do
      within("#new_ticket_type") { first('#ticket_type_company_id option').select_option }

      expect { find("input[name=commit]").click }.not_to change(TicketType, :count)
    end

    it "cannot with an existent name" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: ticket_type.name.to_s }
      find("#ticket_type_company_id").select(ticket_type.company.name)

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

  describe "edit: " do
    it "cannot be edited as nameless" do
      visit edit_admins_event_ticket_type_path(event, ticket_type)

      within("#edit_ticket_type_#{ticket_type.id}") { fill_in 'ticket_type_name', with: "" }
      expect { find("input[name=commit]").click }.not_to change { ticket_type.reload.name }.from(ticket_type.name)

      expect(page).to have_current_path(admins_event_ticket_type_path(event, ticket_type))
    end
  end

  describe "Actions on a ticket type" do
    it "load info view" do
      click_link("ticket_type_#{ticket_type.id}")
      expect(page).to have_current_path(admins_event_ticket_type_path(event, ticket_type))
    end

    it "delete a ticket type" do
      expect { click_link("delete_#{ticket_type.id}") }.to change(TicketType, :count).by(-1)
    end
  end
end
