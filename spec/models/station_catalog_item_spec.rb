# == Schema Information
#
# Table name: station_catalog_items
#
#  price           :float            not null
#
# Indexes
#
#  index_station_catalog_items_on_catalog_item_id  (catalog_item_id)
#  index_station_catalog_items_on_station_id       (station_id)
#
# Foreign Keys
#
#  fk_rails_0ed24067c2  (station_id => stations.id)
#  fk_rails_9e5dde160a  (catalog_item_id => catalog_items.id)
#

require "spec_helper"

RSpec.describe StationCatalogItem, type: :model do
  subject { create(:station_catalog_item) }

  describe "station touch" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(price: 10) }.to change(subject.station, :updated_at)
    end
  end
end
