require 'rails_helper'

RSpec.describe "Management station test", js: true, type: :feature do
  before(:each) do
    user = create(:user, role: "glowball")
    @event = create(:event, name: "Test Event", state: "created")
    @operator_permissions = create(:station, event: @event, category: "operator_permissions", name: "Operator Permissions1")
    @yellow_card = create(:station, event: @event, category: "yellow_card", name: "Yellow card")
    login_as(user, scope: :user)
    visit admins_event_stations_path(@event, group: "event_management")
  end

  describe "Create new management station" do
    before(:each) do
      find("#floaty").click
      find_link("new_station_link").click
    end

    it "is located in correct path " do
      expect(page).to have_current_path(new_admins_event_station_path(@event, group: "event_management"))
    end

    it "without filling name" do
      expect do
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "filling an existent name" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: @yellow_card.name.to_s
        end
        find("input[name=commit]").click
      end.not_to change(Station, :count)
    end

    it "Incident Report" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "INCIDENTREPORT"
          all('#station_category option')[0].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Exhibitor" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "EXHIBITOR"
          all('#station_category option')[1].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Customer Service" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "CUSTOMERSERVICE"
          all('#station_category option')[2].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Operator Permissions" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "OPERATORPERMISSIONS"
          all('#station_category option')[3].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Hospitality Top up" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "HOSPITALITYTOPUP"
          all('#station_category option')[4].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Cs topup refund" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "CSTOPUPREFUND"
          all('#station_category option')[5].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Cs topup refund" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "CSACCREDITATION"
          all('#station_category option')[6].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Cs accreditation" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "GTAGREPLACEMENT"
          all('#station_category option')[7].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "Yellow Card" do
      expect do
        within("#new_station") do
          fill_in 'station_name', with: "YELLOWCARD"
          all('#station_category option')[8].select_option
        end
        find("input[name=commit]").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end
  end

  describe "actions on management station" do
    it "select an management station" do
      find("#station_#{@operator_permissions.id}").click
      expect(page).to have_current_path(admins_event_station_path(@event, @operator_permissions.id))
    end

    it "edit a management station" do
      find("#edit_#{@operator_permissions.id}").click
      expect(page).to have_current_path(edit_admins_event_station_path(@event, @operator_permissions.id))
      within("#edit_station_#{@operator_permissions.id}") { fill_in 'station_name', with: "OP" }
      find("input[name=commit]").click
      expect(page).to have_current_path(admins_event_station_path(@event, @operator_permissions.id))
      find("#undo_link").click
      within 'table' do
        expect(page).not_to have_text @operator_permissions.name.to_s
        expect(page).to have_text "OP"
      end
    end

    it "hide management station" do
      find("#best_in_place_station_#{@operator_permissions.id}_hidden").click
      page.driver.browser.navigate.refresh
      within find(".resource-hidden") do
        expect(page).not_to have_text @yellow_card.name.to_s
        expect(page).to have_text @operator_permissions.name.to_s
      end
    end

    it "clone a monetary station" do
      expect do
        find("#copy_#{@operator_permissions.id}").click
      end.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(@event, Station.last.id))
    end

    it "delete an management station" do
      expect do
        find("#delete_#{@operator_permissions.id}").click
        page.accept_alert
        sleep(1)
      end.to change(Station, :count).by(-1)
    end
  end

  describe "search for a management station" do
    it "type name" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: @operator_permissions.name.to_s }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @yellow_card.name.to_s
        expect(page).to have_text @operator_permissions.name.to_s
      end
    end

    it "type station category" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: @operator_permissions.category.to_s }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @yellow_card.name.to_s
        expect(page).to have_text @operator_permissions.name.to_s
      end
    end

    it "type non-existent station" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: "non-existent" }.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text @yellow_card.name.to_s
        expect(page).not_to have_text @operator_permissions.name.to_s
      end
    end

    it "don't type anything" do
      find("#search_icon").click
      within("#station_search") { fill_in 'fixed-header-drawer-exp', with: "" }.native.send_keys(:return)
      within 'table' do
        expect(page).to have_text @yellow_card.name.to_s
        expect(page).to have_text @operator_permissions.name.to_s
      end
    end
  end
end
