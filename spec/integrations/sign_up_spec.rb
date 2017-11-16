require 'rails_helper'

RSpec.describe "Sign up", type: :feature do
  it "Sign-up when email already exists" do
    @user = create(:user, email: "test@test.com", password: "passwordTest", password_confirmation: "passwordTest")
    visit new_admins_user_path

    within("#new_user") do
      fill_in 'user_email', with: ''
      fill_in 'user_username', with: ''
      fill_in 'user_email', with: @user.email
      fill_in 'user_username', with: @user.email

      find("input[name=commit]").click
      expect(page).not_to have_current_path(admins_events_path)
    end
  end

  it "Passwords don't match at Signing up" do
    visit new_admins_user_path
    within("#new_user") do
      fill_in 'user_email', with: ''
      fill_in 'user_username', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_password_confirmation', with: ''
      fill_in 'user_email', with: "emailtest@test.com"
      fill_in 'user_username', with: "emailtest@test.com"
      fill_in 'user_password', with: "CorrectPWD"
      fill_in 'user_password_confirmation', with: "WrongPWD"

      find("input[name=commit]").click
      expect(page).not_to have_current_path(admins_events_path)
    end
  end

  it "Successful Sign-up" do
    visit new_admins_user_path
    within("#new_user") do
      fill_in 'user_email', with: ''
      fill_in 'user_username', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_password_confirmation', with: ''
      fill_in 'user_email', with: "emailtest@test.com"
      fill_in 'user_username', with: "emailtest@test.com"
      fill_in 'user_password', with: "CorrectPWD"
      fill_in 'user_password_confirmation', with: "CorrectPWD"

      find("input[name=commit]").click
      expect(page).to have_current_path(admins_events_path)
    end
  end
end
