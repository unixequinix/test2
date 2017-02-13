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

FactoryGirl.define do
  factory :station_catalog_item do
    sequence(:price) { |n| n.to_f + 1 }
    catalog_item
    station
  end
end
