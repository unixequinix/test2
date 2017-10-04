require 'rails_helper'

RSpec.describe "the signin process", type: :feature do
  before :each do
    @user = create(:user, role: 0)
    create(:event)
    login_as(@user, scope: :user)
  end

  it "checks all root page links" do
    # Visit URL
    # @driver.navigate.to("#{@base_url}/admins/events")
    # Clicks events
    # @driver.find_element(:link, 'stars Events').click
    # @driver.find_element(:link, 'stars Event Series').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/event_series"
    # @driver.find_element(:link, 'add_alertAlerts').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/alerts"
    # @driver.find_element(:link, 'account_circleMy Profile').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/users/#{@user.id}"
    # @driver.find_element(:link, 'create Password').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/users/#{@user.id}/edit"
    # @driver.find_element(:link, 'people Users').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/users"
    # @driver.find_element(:link, 'settings_cell Devices').click
    # expect(@driver.current_url).should eq "#{@base_url}/admins/devices"
    # @driver.find_element(:id, 'out').click

    # Visit URL
    visit admins_events_path
    # Clicks events

    find_link("events_layout_link").click
    expect(page).to have_current_path("/admins/events")
    find_link("event_series_layout_link").click
    expect(page).to have_current_path("/admins/event_series")
    find_link("users_layout_link").click
    expect(page).to have_current_path("/admins/users")
    find_link("devices_layout_link").click
    expect(page).to have_current_path("/admins/devices")
  end
end
