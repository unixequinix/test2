require 'rails_helper'

RSpec.describe "Accreditation stations info view tests", type: :feature do
  let!(:user) { create(:user, role: "glowball") }
  let!(:event) { create(:event, name: "Test Event", state: "created") }
  let!(:station) { create(:station, event: event, category: "box_office", name: "Box Office") }
  let!(:catalog_item) { create(:pack, :with_credit, event: event) }
  let!(:station_catalog_item) { create(:station_catalog_item, station: station, catalog_item: catalog_item) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_station_path(event, station)
  end

  include_examples "edit station"

  describe "Actions on items" do
    before { visit admins_event_station_path(event, station.id) }

    it "can be done if event is created" do
      event.update! state: "created"
      expect { click_link("delete_#{station_catalog_item.id}") }.to change(station.station_catalog_items, :count).by(-1)
    end

    it "cannot be done if event is launched" do
      event.update! state: "launched"
      expect { click_link("delete_#{station_catalog_item.id}") }.not_to change(station.station_catalog_items, :count)
    end
  end
end
