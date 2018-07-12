require 'rails_helper'

RSpec.describe "Tests on ticket type view", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }
  let(:catalog_item) { create(:catalog_item, event: event) }
  let!(:ticket_type) { create(:ticket_type, event: event, catalog_item: catalog_item, name: "Friday") }
  let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }

  before do
    login_as(user, scope: :user)
    visit admins_event_ticket_types_path(event)
  end

  describe "create:" do
    before { click_link("new_ticket_type") }

    it "with name" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME" }

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(page).to have_current_path admins_event_ticket_types_path(event, operator: false)
      expect(TicketType.last.name).to eql("TESTTICKETTYPENAME")
    end

    it "cannot without a name" do
      expect { find("input[name=commit]").click }.not_to change(TicketType, :count)
    end

    it "cannot with an existent name" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: ticket_type.name.to_s }
      expect { find("input[name=commit]").click }.not_to change(TicketType, :count)
    end

    it "allows to assign a catalog_item" do
      within("#new_ticket_type") { fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME" }
      find("#ticket_type_catalog_item_id").select(event.credit.name)

      expect { find("input[name=commit]").click }.to change(TicketType, :count).by(1)
      expect(TicketType.last.catalog_item).to eql(event.credit)
    end
  end

  describe "edit: " do
    before(:each) { visit edit_admins_event_ticket_type_path(event, ticket_type) }

    it "cannot be edited as nameless" do
      within("#edit_ticket_type_#{ticket_type.id}") { fill_in 'ticket_type_name', with: "" }
      expect { find("input[name=commit]").click }.not_to change { ticket_type.reload.name }.from(ticket_type.name)
      expect(page).to have_current_path(admins_event_ticket_type_path(event, ticket_type))
    end

    it "cannot be edited as existent name" do
      existent_ticket_type = create(:ticket_type, event: event, catalog_item: catalog_item, name: "Saturday")
      within("#edit_ticket_type_#{ticket_type.id}") { fill_in 'ticket_type_name', with: existent_ticket_type.name }
      expect { find("input[name=commit]").click }.not_to change { ticket_type.reload.name }.from(ticket_type.name)
      expect(page).to have_current_path(admins_event_ticket_type_path(event, ticket_type))
    end

    it "edit name and catalog item" do
      within("#edit_ticket_type_#{ticket_type.id}") { fill_in 'ticket_type_name', with: "Saturday" }
      find("#ticket_type_catalog_item_id").select(event.virtual_credit.name)
      expect { find("input[name=commit]").click }.to change { ticket_type.reload.name }.to("Saturday")
      expect(page).to have_current_path(admins_event_ticket_types_path(event, operator: false))
    end
  end
end
