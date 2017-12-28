require 'rails_helper'

RSpec.describe "Creating new Packs", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :admin) }
  let(:pack) { create(:pack, event: event) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_packs_path(event)
  end

  describe "Creating Packs correctly" do
    it "Is located in /acceses" do
      find_link("new_pack_link").click
      expect(page).to have_current_path(new_admins_event_pack_path(event))
    end
  end
end
