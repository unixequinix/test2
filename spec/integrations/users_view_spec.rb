require 'rails_helper'

RSpec.describe "Users view", type: :feature do
  let!(:glowball) { create(:user, role: "glowball") }
  let!(:admin) { create(:user, role: "admin") }

  before { login_as(glowball, scope: :user) }

  describe "users view link" do
    before { visit admin_root_path }

    it "all users are displayed" do
      click_link("users_layout_link")
      within("#user_list") do
        expect(page).to have_current_path(admins_users_path)
        expect(page).to have_text glowball.username.to_s
        expect(page).to have_text admin.username.to_s
      end
    end
  end

  describe "actions in user view" do
    before { visit admins_users_path }

    it "select a user" do
      click_link("user_#{admin.id}_email")
      expect(page).to have_current_path(admins_user_path(admin.id))
    end

    it "add a user" do
      click_link("new_user_link")
      expect(page).to have_current_path(new_admins_user_path)
    end

    it "delete a user" do
      expect { click_link("user_#{admin.id}_delete") }.to change(User, :count).by(-1)
    end
  end
end
