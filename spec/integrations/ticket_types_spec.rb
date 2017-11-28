require 'rails_helper'

RSpec.describe "Create a ticket type", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before do
    @company = create(:company, event: event)
    login_as(user, scope: :user)
    visit admins_event_ticket_types_path(event)
    find("#floaty").click
    find_link("new_ticket_type").click
  end
  it "is located in ticket_types/new" do
    expect(page).to have_current_path(new_admins_event_ticket_type_path(event))
  end

  it "can be created by only filling name and company" do
    expect do
      within("#new_ticket_type") do
        fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME"
        first('#ticket_type_company_id option').select_option
      end

      find("input[name=commit]").click
    end.to change(TicketType, :count).by(1)

    expect(page).to have_current_path admins_event_ticket_types_path(event)
  end

  it "can'b be done without filling a ticket type name" do
    expect do
      within("#new_ticket_type") do
        first('#ticket_type_company_id option').select_option
      end

      find("input[name=commit]").click
    end.not_to change(TicketType, :count)

    expect(page).to have_current_path admins_event_ticket_types_path(event)
  end

  it "can be done filling everything" do
    expect do
      within("#new_ticket_type") do
        fill_in 'ticket_type_name', with: "TESTTICKETTYPENAME"
        fill_in 'ticket_type_company_code', with: "C0MP4NYC0D3"
        first('#ticket_type_company_id option', minimum: 1).select_option
        first('#ticket_type_catalog_item_id option', minimum: 1).select_option
      end

      find("input[name=commit]").click
    end.to change(TicketType, :count).by(1)

    ticket_type = event.ticket_types.find_by(name: "TESTTICKETTYPENAME")
    expect(page).to have_current_path admins_event_ticket_types_path(event)

    expect(ticket_type.name).to eq("TESTTICKETTYPENAME")
    expect(ticket_type.company_code).to eq("C0MP4NYC0D3")
    expect(ticket_type.company).to eq @company
  end
end
