require 'rails_helper'

RSpec.describe "Creating a ticket type", type: :feature, js: true do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }
  let!(:company) { create(:company, event: event) }

  before do
    login_as(user, scope: :user)
    visit new_admins_event_ticket_type_path(event)
  end

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
