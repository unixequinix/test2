require 'rails_helper'

RSpec.describe "the signin process", type: :feature do
  before :each do
    @user = create(:user, role: 2)
    create(:event)
    create(:team, leader: @user)
    login_as(@user, scope: :user)
  end

  it "checks all root page links" do
    visit admins_events_path
    find_link("events_layout_link").click
    expect(page).to have_current_path("/admins/events")
    find_link("event_series_layout_link").click
    expect(page).to have_current_path("/admins/event_series")
    find_link("users_layout_link").click
    expect(page).to have_current_path("/admins/users")
    find_link("devices_layout_link").click
    expect(page).to have_current_path("/admins/users/#{@user.id}/team/devices")
  end
end
