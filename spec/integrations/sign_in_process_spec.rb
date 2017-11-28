require 'rails_helper'

RSpec.describe "the signin process", type: :feature do
  let!(:user) { create(:user, email: "test@test.com", password: "foopassword", password_confirmation: "foopassword") }
  before { visit new_user_session_path }

  it "signs me in when correct data is supplied" do
    within("#new_user") do
      fill_in 'user_login', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_login', with: user.email
      fill_in 'user_password', with: user.password
    end

    find("input[name=commit]").click
    expect(page).to have_current_path(admins_events_path)
  end

  it "does not sign me in when incorrect data is supplied" do
    within("#new_user") do
      fill_in 'user_login', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_login', with: user.email
      fill_in 'user_password', with: "notgoodpassword"
    end

    find("input[name=commit]").click
    expect(page).to have_current_path(new_user_session_path)
  end
end
