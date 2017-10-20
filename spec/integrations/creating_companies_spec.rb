require 'rails_helper'

RSpec.describe "Create a company", type: :feature do
  let(:user) { create(:user, role: "admin") }
  let(:event) { create(:event, state: "created") }

  before do
    login_as(user, scope: :user)
    visit admins_event_companies_path(event)
    find("#floaty").click
    find_link("new_company_link").click
  end

  it "is located in companies/new" do
    expect(page).to have_current_path(new_admins_event_company_path(event))
  end

  it "can be created by filling name" do
    expect do
      within("#new_company") do
        fill_in 'company_name', with: "COMPANYNAME"
      end

      find("input[name=commit]").click
    end.to change(Company, :count).by(1)

    company = event.companies.find_by(name: "COMPANYNAME")
    expect(page).to have_current_path admins_event_companies_path(event)
    expect(company.name).to eq("COMPANYNAME")
  end

  it "can't be done without filling a name" do
    expect do
      find("input[name=commit]").click
    end.not_to change(Company, :count)

    expect(page).to have_current_path admins_event_companies_path(event)
  end
end
