require 'rails_helper'

RSpec.describe "Accreditation stations info view tests", type: :feature do
  let!(:user) { create(:user, role: "glowball") }
  let!(:event) { create(:event, name: "Test Event", state: "created") }
  let!(:station) { create(:station, event: event, category: "box_office", name: "Box Office") }
  let!(:catalog_item) { create(:catalog_item, event: event) }
  let!(:station_catalog_item) { create(:station_catalog_item, station: station, catalog_item: catalog_item) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_station_path(event, station)
  end

  include_examples "edit station"

  describe "Box Office:" do
    before { visit admins_event_station_path(event, station.id) }

    it "create new catalog item" do
      within("#new_station_catalog_item") do
        fill_in 'station_catalog_item_price', with: "20"
        all('#station_catalog_item_catalog_item_id option')[2].select_option
      end
      expect { find("input[name=commit]").click }.to change(station.station_catalog_items, :count).by(1)
    end

    it "new catalog item without price" do
      within("#new_station_catalog_item") do
        all('#station_catalog_item_catalog_item_id option')[2].select_option
      end
      expect { find("input[name=commit]").click }.not_to change(station.station_catalog_items, :count)
    end

    it "new catalog item with incorrect price" do
      within("#new_station_catalog_item") do
        fill_in 'station_catalog_item_price', with: "NaN"
        all('#station_catalog_item_catalog_item_id option')[2].select_option
      end
      expect { find("input[name=commit]").click }.not_to change(station.station_catalog_items, :count)
    end
  end

  describe "Customer Portal:" do
    let!(:customer_portal) { create(:station, event: event, category: "customer_portal", name: "Customer portal") }
    before { visit admins_event_station_path(event, customer_portal.id) }

    it "create new catalog item" do
      within("#new_station_catalog_item") do
        fill_in 'station_catalog_item_price', with: "20"
        all('#station_catalog_item_catalog_item_id option')[2].select_option
      end
      expect { find("input[name=commit]").click }.to change(customer_portal.station_catalog_items, :count).by(1)
    end

    it "new catalog item without category" do
      within("#new_station_catalog_item") do
        fill_in 'station_catalog_item_price', with: "20"
      end
      expect { find("input[name=commit]").click }.not_to change(customer_portal.station_catalog_items, :count)
    end
  end

  describe "Staff Accreditation:" do
    let!(:staff_accreditation) { create(:station, event: event, category: "staff_accreditation", name: "Staff Accreditation") }
    before { visit admins_event_station_path(event, staff_accreditation.id) }

    it "create new catalog item" do
      within("#new_station_catalog_item") do
        all('#station_catalog_item_catalog_item_id option')[2].select_option
      end
      expect { find("input[name=commit]").click }.to change(staff_accreditation.reload.station_catalog_items, :count).by(1)
    end
  end

  describe "CS Accreditation:" do
    let!(:cs_accreditation) { create(:station, event: event, category: "cs_accreditation", name: "Cs Accreditation") }
    before { visit admins_event_station_path(event, cs_accreditation.id) }

    it "create new catalog item" do
      expect { find("input[name=commit]").click }.not_to change(cs_accreditation.station_catalog_items, :count)
    end
  end

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
