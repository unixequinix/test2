require 'rails_helper'

RSpec.describe "Sign up process", type: :feature do
  let(:user) { create(:user, email: "test@test.com", password: "passwordTest", password_confirmation: "passwordTest") }

  before { visit new_admins_user_path }

  it "is not valid if email is present" do
    within("#new_user") do
      fill_in 'user_email', with: user.email
      fill_in 'user_username', with: user.email
    end

    expect { find("input[name=commit]").click }.not_to change(User, :count)
    expect(page).to have_current_path(admins_events_path)
  end

  it "is not valid if passwords dont match" do
    within("#new_user") do
      fill_in 'user_email', with: "emailtest@test.com"
      fill_in 'user_username', with: "emailtest@test.com"
      fill_in 'user_password', with: "CorrectPWD"
      fill_in 'user_password_confirmation', with: "WrongPWD"
    end

    find("input[name=commit]").click
    expect(page).not_to have_current_path(admins_events_path)
  end

  it "can be done succesfully" do
    within("#new_user") do
      fill_in 'user_email', with: "emailtest@test.com"
      fill_in 'user_username', with: "emailtest@test.com"
      fill_in 'user_password', with: "CorrectPWD"
      fill_in 'user_password_confirmation', with: "CorrectPWD"
    end

    expect { find("input[name=commit]").click }.to change(User, :count).by(1)
    expect(page).to have_current_path(admins_events_path)
  end
end
