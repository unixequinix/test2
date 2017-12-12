require 'rails_helper'

RSpec.describe "Monetary stations view tests", js: true, type: :feature do
  before(:each) do
    user = create(:user, role: "glowball")
    @event = create(:event, name: "Test Event", state: "created")
    @bar = create(:station, event: @event, category: "bar", name: "Bar1")
    @vendor = create(:station, event: @event, category: "vendor", name: "Vendor1")
    login_as(user, scope: :user)
    visit admins_event_stations_path(@event, group: "monetary")
  end

  describe "Create new monetary station" do
    before(:each) do
      find("#floaty").click
      find_link("new_station_link").click
    end

    it "is located in correct path " do
      expect(page).to have_current_path(new_admins_event_station_path(@event, group: "monetary"))
    end

    it "without filling name" do
      expect do
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "filling an existent name" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: @bar.name.to_s
        end
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "Bar" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "BAR"
          all('#station_category option')[0].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Vendor" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "VENDOR"
          all('#station_category option')[1].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Top up Refund" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TOPUPREFUND"
          all('#station_category option')[2].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end
  end

  describe "actions on monetary station" do
    it "select an monetary station" do
      find("#station_#{@bar.id}").click
      expect(page).to have_current_path(admins_event_station_path(@event, @bar.id))
    end

    it "edit a monetary station" do
      find("#edit_#{@bar.id}").click
      expect(page).to have_current_path(edit_admins_event_station_path(@event, @bar.id))
      within("#edit_station_#{@bar.id}") { fill_in 'station_name', with: "Bar2" }
      find("input[name=commit]").click
      expect(page).to have_current_path(admins_event_station_path(@event, @bar.id))
      find("#undo_link").click
      within 'table' do
        expect(page).not_to have_text @bar.name.to_s
        expect(page).to have_text "Bar2"
      end
    end

    it "hide monetary station" do
      find("#best_in_place_station_#{@bar.id}_hidden").click
      page.driver.browser.navigate.refresh
      within find(".resource-hidden") do
        expect(page).not_to have_text @vendor.name.to_s
        expect(page).to have_text @bar.name.to_s
      end
    end

    it "clone a monetary station" do
      expect do
        find("#copy_#{@bar.id}").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "delete a monetary station" do
      expect do
        find("#delete_#{@bar.id}").click
        page.accept_alert
        sleep(1)
      end.to change(Station, :count).by(-1)
    end
  end

  describe "search for a monetary station" do
    it "type name" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: @bar.name.to_s }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @vendor.name.to_s
        expect(page).to have_text @bar.name.to_s
      end
    end

    it "type station category" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: @bar.category.to_s }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @vendor.name.to_s
        expect(page).to have_text @bar.name.to_s
      end
    end

    it "type non-existent station" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: "non-existent" }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @vendor.name.to_s
        expect(page).not_to have_text @bar.name.to_s
      end
    end

    it "don't type anything" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: "" }.native.send_keys(:return)
      within 'table' do
        expect(page).to have_text @vendor.name.to_s
        expect(page).to have_text @bar.name.to_s
      end
    end
  end
end
