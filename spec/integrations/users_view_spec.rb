require 'rails_helper'

RSpec.describe "Users view", js:true, type: :feature do

  before(:each) do
    @user_glowball = create(:user, role:"glowball")
    @user_admin = create(:user, role:"admin")
    login_as(@user_glowball, scope: :user)

  end

  describe "users view link" do
    before do
      visit admin_root_path
    end
    it "all users are displayed" do
      find("#user_dropdown").hover
      find("#users_layout_link").click
      expect(page).to have_current_path(admins_users_path)
      within 'table' do
        expect(page).to have_text "#{@user_glowball.username}"
        expect(page).to have_text "#{@user_admin.username}"
      end
    end
  end

  describe "actions in user view" do
    before do
      visit admins_users_path
    end

    it "select an user" do
      find_by_id("#{@user_admin.id}_email").click
      expect(page).to have_current_path(admins_user_path(@user_admin.id))
    end

    it "add an user" do
      find("#floaty").hover
      find("#new_user_link").click
      expect(page).to have_current_path(new_admins_user_path)
    end

    it "delete an user" do
      expect do
        find_by_id("#{@user_admin.id}_delete").click
        page.accept_alert
        sleep(1)
      end.to change(User, :count).by(-1)
    end
  end

  describe "search user" do
    before do
      visit admins_users_path
    end

    it "type username" do
      find("#search_icon").click
      within("#user_search") {fill_in 'fixed-header-drawer-exp', with: "#{@user_admin.username}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@user_glowball.username}"
        expect(page).to have_text "#{@user_admin.username}"
      end
    end

    it "type email" do
      find("#search_icon").click
      within("#user_search") {fill_in 'fixed-header-drawer-exp', with: "#{@user_admin.email}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@user_glowball.email}"
        expect(page).to have_text "#{@user_admin.email}"
      end
    end

    it "type non-existent user name" do
      find("#search_icon").click
      within("#user_search") {fill_in 'fixed-header-drawer-exp', with: "non-existent"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@user_glowball.username}"
        expect(page).not_to have_text "#{@user_admin.username}"
      end
    end

    it "don't type user name" do
      find("#search_icon").click
      within("#user_search") {fill_in 'fixed-header-drawer-exp', with: ""}.native.send_keys(:return)
      within 'table' do
        expect(page).to have_text "#{@user_glowball.username}"
        expect(page).to have_text "#{@user_admin.username}"
      end
    end
  end

end
