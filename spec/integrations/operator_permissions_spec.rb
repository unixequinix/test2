require 'rails_helper'

RSpec.describe "Operator Permissions in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: "admin") }
  let!(:station1) { create(:station, name: "Station 1", event: event) }
  let!(:station2) { create(:station, name: "Station 2", event: event) }
  let!(:catalog_item1) { create(:catalog_item, group: "Glownet", event: event, type: 'OperatorPermission') }
  let!(:catalog_item2) { create(:catalog_item, station: station2,  event: event, type: 'OperatorPermission') }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "create: " do
    before { visit new_admins_event_operator_permission_path(event) }

    it "cant't be created without filling group or station" do
      within("#new_operator_permission") do
        all('#operator_permission_role option')[1].select_option
      end
      expect { find("input[name=commit]").click }.not_to change(OperatorPermission, :count)
    end

    it "can be created filling role and group" do
      within("#new_operator_permission") do
        all('#operator_permission_role option')[1].select_option
        all('#operator_permission_group option')[1].select_option
      end
      expect { find("input[name=commit]").click }.to change { event.operator_permissions.count }.by(1)
    end

    it "can be created filling role and station" do
      within("#new_operator_permission") do
        all('#operator_permission_role option')[1].select_option
        all('#operator_permission_station_id option')[1].select_option
      end
      expect { find("input[name=commit]").click }.to change { event.operator_permissions.count }.by(1)
    end

    it "cant't be created by filling role, group and station" do
      within("#new_operator_permission") do
        all('#operator_permission_role option')[1].select_option
        all('#operator_permission_group option')[1].select_option
        all('#operator_permission_station_id option')[1].select_option
      end
      expect { find("input[name=commit]").click }.not_to change(OperatorPermission, :count)
    end
  end

  describe "delete: " do
    before { visit admins_event_operator_permission_path(event, catalog_item1) }

    it "can be achieved if event is in 'created' state" do
      event.update! state: "created"
      expect { click_link("delete") }.to change(OperatorPermission, :count).by(-1)
    end

    it "can't be achieved if event is in 'launched' state" do
      event.update! state: "launched"
      expect { click_link("delete") }.not_to change(OperatorPermission, :count)
    end
  end

  describe "edit: " do
    it "Cannot add a station already has role and group" do
      visit edit_admins_event_operator_permission_path(event, catalog_item1)
      find("option[value='#{event.stations[0].id}']").click
      expect { find("input[name=commit]").click }.not_to change { catalog_item1.reload.station }.from(nil)
    end

    it "Cannot add a group already has role and sation" do
      visit edit_admins_event_operator_permission_path(event, catalog_item2)
      find("option[value='glownet']").click
      expect { find("input[name=commit]").click }.not_to change { catalog_item2.reload.group }.from(nil)
    end
  end
end
