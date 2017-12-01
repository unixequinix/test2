require 'rails_helper'

RSpec.describe "Companies in the admin panel", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  describe "create: " do
    before do
      login_as(user, scope: :user)
      visit new_admins_event_company_path(event)
    end

    it "only needs name" do
      within("#new_company") { fill_in 'company_name', with: "COMPANYNAME" }
      expect { find("input[name=commit]").click }.to change(Company, :count).by(1)
    end

    it "name is required" do
      within("#new_company") { fill_in 'company_name', with: "" }
      expect { find("input[name=commit]").click }.not_to change(Company, :count)
    end
  end
end
