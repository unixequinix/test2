require 'rails_helper'

RSpec.describe "Accreditation stations info view tests", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let(:event) { create(:event, name: "Test Event", state: "created") }
  let!(:station) { create(:station, event: event, category: "access_control", name: "Friday IN") }
  let!(:access) { create(:access, event: event, name: "Vip") }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_station_path(event, station)
  end

  include_examples "edit station"

  describe "Create new access control gate:" do
    it "create IN" do
      within("#new_access_control_gate") do
        all('#access_control_gate_direction option')[1].select_option
        all('#access_control_gate_access_id option')[1].select_option
      end
      expect { find("input[name=commit]").click }.to change(station.access_control_gates, :count).by(1)
    end

    it "create OUT" do
      within("#new_access_control_gate") do
        all('#access_control_gate_direction option')[2].select_option
        all('#access_control_gate_access_id option')[1].select_option
      end
      expect { find("input[name=commit]").click }.to change(AccessControlGate, :count).by(1)
    end

    it "without direction" do
      within("#new_access_control_gate") { all('#access_control_gate_access_id option')[1].select_option }
      expect { find("input[name=commit]").click }.not_to change(AccessControlGate, :count)
    end

    it "without access" do
      within("#new_access_control_gate") { all('#access_control_gate_direction option')[1].select_option }
      expect { find("input[name=commit]").click }.not_to change(AccessControlGate, :count)
    end
  end

  describe "delete access control gates: " do
    let!(:gate) { create(:access_control_gate, station: station, access: access) }

    it "can be done if event is created" do
      event.update! state: "created"
      visit admins_event_station_path(event, station)
      expect { click_link("delete_#{gate.id}", visible: false) }.to change(AccessControlGate, :count).by(-1)
    end

    it "cannot be done if event is launched" do
      event.update! state: "launched"
      visit admins_event_station_path(event, station)
      expect(page).to have_no_link("delete_#{gate.id}")
    end

    it "cannot be done if event is closed" do
      event.update! state: "closed"
      visit admins_event_station_path(event, station)
      expect(page).to have_no_link("delete_#{gate.id}")
    end
  end
end
