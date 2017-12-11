require 'rails_helper'

RSpec.describe "Access stations view tests", js:true, type: :feature do

  before(:each) do
    user = create(:user, role:"glowball")
    @event = create(:event, name:"Test Event", state:"created")
    @box_office = create(:station, event:@event, category:"box_office", name:"Box Office")
    @ticket_validation = create(:station, event:@event, category:"ticket_validation", name:"Ticket Validation")
    @check_in = create(:station, event:@event, category:"check_in", name:"Checkin")
    @access_control = create(:station, event:@event, category:"access_control", name:"Access Control")
    login_as(user, scope: :user)
    visit admins_event_stations_path(@event, group:"access")
  end


  describe "Create new access station" do

    before(:each) do
      find("#floaty").click
      find_link("new_station_link").click
    end

    it "is located in correct path " do
      expect(page).to have_current_path(new_admins_event_station_path(@event, group:"access"))
    end

    it "without filling name" do
      expect do
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "filling an existent name" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "#{@box_office.name}"
        end
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "Ticket Validation" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TESTTICKETVALIDATION"
          all('#station_category option')[0].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Checkin" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TESTCHECKIN"
          all('#station_category option')[1].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Box Office" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TESTBOXOFFICE"
          all('#station_category option')[2].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Staff Acreditation" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TESTSTAFFACREDITATION"
          all('#station_category option')[3].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Access control" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "TESTACCESSCONTROL"
          all('#station_category option')[4].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)

      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end
  end

  describe "actions on access station" do

    it "select an access station" do
      find_by_id("#{@box_office.id}").click
      expect(page).to have_current_path(admins_event_station_path(@event, @box_office.id))
    end

    it "edit a access station" do
      find_by_id("edit_#{@box_office.id}").click
      expect(page).to have_current_path(edit_admins_event_station_path(@event, @box_office.id))
      within("#edit_station_#{@box_office.id}"){fill_in 'station_name', with:"BoxOffice2"}
      find("input[name=commit]").click
      expect(page).to have_current_path(admins_event_station_path(@event, @box_office.id))
      find("#undo_link").click
      within 'table' do
        expect(page).not_to have_text "#{@box_office.name}"
        expect(page).to have_text "BoxOffice2"
      end
    end

    it "hide access station" do
      find("#best_in_place_station_#{@box_office.id}_hidden").click
      page.driver.browser.navigate.refresh
      within find(".resource-hidden") do
        expect(page).not_to have_text "#{@ticket_validation.name}"
        expect(page).to have_text "#{@box_office.name}"
      end
    end

    it "clone a monetary station" do
      expect do
        find_by_id("copy_#{@box_office.id}").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "delete an access station" do
      expect do
        find_by_id("delete_#{@box_office.id}").click
        page.accept_alert
        sleep(1)
      end.to change(Station, :count).by(-1)
    end


  end

  describe "search for a access station" do

    it "type name" do
      find("#search_icon").click
      within("#station_search") {fill_in 'fixed-header-drawer-exp', with: "#{@box_office.name}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@ticket_validation.name}"
        expect(page).to have_text "#{@box_office.name}"
      end
    end

    it "type station category" do
      find("#search_icon").click
      within("#station_search") {fill_in 'fixed-header-drawer-exp', with: "#{@box_office.category}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@ticket_validation.name}"
        expect(page).to have_text "#{@box_office.name}"
      end
    end

    it "type non-existent station" do
      find("#search_icon").click
      within("#station_search") {fill_in 'fixed-header-drawer-exp', with: "non-existent"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@ticket_validation.name}"
        expect(page).not_to have_text "#{@box_office.name}"
      end
    end

    it "don't type anything" do
      find("#search_icon").click
      within("#station_search") {fill_in 'fixed-header-drawer-exp', with: ""}.native.send_keys(:return)
      within 'table' do
        expect(page).to have_text "#{@ticket_validation.name}"
        expect(page).to have_text "#{@box_office.name}"
      end
    end
  end
end
