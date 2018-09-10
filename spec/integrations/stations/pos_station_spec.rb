require 'rails_helper'

RSpec.describe "POS stations info view tests", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let(:event) { create(:event, name: "Test Event", state: "created") }
  let(:station) { create(:station, event: event, category: "bar", name: "Bar1") }
  let!(:product_bar) { create(:product, station: station) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_event_station_path(event, station)
  end

  include_examples "edit station"

  describe "Bar:" do
    before { visit admins_event_station_path(event, station.id) }

    it "create new product" do
      within("#new_product") do
        fill_in 'product_price', with: "3"
        fill_in 'product_name', with: "Beer"
      end
      expect { find("#add_product_commit").click }.to change(station.products, :count).by(1)
    end

    it "new product without price" do
      within("#new_product") { fill_in 'product_name', with: "Beer" }
      expect { find("#add_product_commit").click }.not_to change(station.products, :count)
    end

    it "new product with incorrect price" do
      within("#new_product") do
        fill_in 'product_price', with: "NaN"
        fill_in 'product_name', with: "Beer"
      end
      expect { find("#add_product_commit").click }.not_to change(station.products, :count)
    end
  end

  describe "Vendor:" do
    let(:vendor) { create(:station, event: event, category: "vendor", name: "Vendor1") }
    let(:product_vendor) { create(:product, station: vendor) }

    before { visit admins_event_station_path(event, vendor.id) }

    it "create new product" do
      within("#new_product") do
        fill_in 'product_price', with: "20"
        fill_in 'product_name', with: "T-shirt"
      end
      expect { find("#add_product_commit").click }.to change(vendor.products, :count).by(1)
    end

    it "new product without name" do
      within("#new_product") { fill_in 'product_price', with: "20" }
      expect { find("#add_product_commit").click }.not_to change(vendor.products, :count)
    end

    it "new product with existent name" do
      within("#new_product") { fill_in 'product_price', with: product_vendor.name }
      expect { find("#add_product_commit").click }.not_to change(vendor.products, :count)
    end
  end

  describe "delete a product" do
    before { visit admins_event_station_path(event, station.id) }

    it "can be done if event is created" do
      event.update state: "created"
      expect { click_link("delete_#{product_bar.id}") }.to change(station.products, :count).by(-1)
    end

    it "cannot be done if event is launched" do
      event.update state: "launched"
      expect { click_link("delete_#{product_bar.id}") }.not_to change(station.products, :count)
    end
  end
end
