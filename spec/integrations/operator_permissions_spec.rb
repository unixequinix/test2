require 'rails_helper'

RSpec.describe "Operator Permissions in the admin panel", js: true, type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: "admin") }
  let!(:station1) { create(:station, name: "Station 1", event: event) }
  let!(:station2) { create(:station, name: "Station 2", event: event) }
  let!(:catalog_item1) { create(:catalog_item, group: "Glownet", event: event, type: 'OperatorPermission') }
  let!(:catalog_item2) { create(:catalog_item, station_id: event.stations[1].id,  event: event, type: 'OperatorPermission') }


  before(:each) do
    login_as(user, scope: :user)
  end

  describe "create: " do
    before { visit new_admins_event_operator_permission_path(event) }

	  it "cant't be created without filling group or station" do
     	find("option[value='operator']").click
    	find("input[name=commit]").click
    	expect(event.operator_permissions.count).to eq(2)
    end

    it "can be created filling role and group" do
     	find("option[value='operator']").click
    	find("option[value='checkin']").click
    	find("input[name=commit]").click
    	expect(event.operator_permissions.count).to eq(3)
    end

    it "can be created filling role and station" do
     	find("option[value='manager']").click
    	find("option[value='#{event.stations[1].id}']").click
    	find("input[name=commit]").click
    	expect(event.operator_permissions.count).to eq(3)
    end

    it "cant't be created by filling role, group and station" do
     	find("option[value='operator']").click
     	find("option[value='checkin']").click
    	find("option[value='#{event.stations[1].id}']").click
    	find("input[name=commit]").click
    	expect(event.operator_permissions.count).to eq(2)
    end
  end   

  describe "delete: " do
    before { visit admins_event_operator_permission_path(event, catalog_item1) }

    it "can be achieved if event is in 'created' state" do
      event.update! state: "created"
      find('.floaty-btn').click
      find("#delete").click 
      page.accept_alert
      sleep(1)
      expect(event.operator_permissions.count).to eq(1)
    end

    it "can't be achieved if event is in 'launched' state" do
      find('.floaty-btn').click
      find("#delete").click 
      page.accept_alert
      sleep(1)
      expect(event.operator_permissions.count).to eq(2)
    end
  end

  describe "edit: " do

    it "Cannot add a station already has role and group" do
      visit edit_admins_event_operator_permission_path(event, catalog_item1)
      find("option[value='#{event.stations[0].id}']").click
	  find("input[name=commit]").click
	  expect(event.catalog_items[1].station_id).not_to eq(station1.id)
    end

    it "Cannot add a group already has role and sation" do
      visit edit_admins_event_operator_permission_path(event, catalog_item2)
      find("option[value='glownet']").click
	  find("input[name=commit]").click
	  visit admins_event_operator_permissions_path(event, catalog_item2)
	  expect(event.catalog_items[2].group).not_to eq("glownet")
    end
  end  

end 