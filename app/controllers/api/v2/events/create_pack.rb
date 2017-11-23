require 'rails_helper'

RSpec.describe "Creating new Packs", js: true, type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :admin) }
  let(:pack) { create(:pack) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_packs_path(event)
  end

  describe "Creating Packs correctly" do
    before(:each) do
      visit admins_event_packs_path(event)
      find("#floaty").click
      find_link("new_pack_link").click
    end

    it "Is located in /acceses" do
      expect(page).to have_current_path(new_admins_event_access_path(event))
    end
  end
end
