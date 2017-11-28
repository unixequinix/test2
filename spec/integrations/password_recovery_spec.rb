require 'rails_helper'

RSpec.describe "Password recovery for admin users", js:true, type: :feature do

  let(:user) { create(:user, role: "admin", password: "oldpassword", password_confirmation: "oldpassword") }
  before do
    visit new_user_password_path
  end

  it "fill existent email" do
    within("#new_user") { fill_in 'user_email', with: user.email }
    expect do
      find("input[name=commit]").click
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
    expect(unread_emails_for(user.email)).to be_present
    open_email(user.email, with_subject: 'Reset password instructions')
    click_first_link_in_email
    within("#new_user") do
      fill_in 'user_password', with: "newpassword"
      fill_in 'user_password_confirmation', with: "newpassword"
      find("input[name=commit]").click
    end

    expect(page).to have_current_path(admins_events_path)
    find("#user_dropdown").hover
    find("#log_out_link").click
    expect(page).to have_current_path(new_user_session_path)
    within("#new_user") do
      fill_in 'user_login', with: ''
      fill_in 'user_password', with: ''
      fill_in 'user_login', with: user.email
      fill_in 'user_password', with: "newpassword"
    end

    find("input[name=commit]").click

    expect(page).to have_current_path(admins_events_path)
  end

  it "fill non-existent email" do
    within("#new_user") { fill_in 'user_email', with: "non-existent@email.com" }
    find("input[name=commit]").click
  end

end
