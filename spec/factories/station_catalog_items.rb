# == Schema Information
#
# Table name: station_catalog_items
#
#  created_at      :datetime         not null
#  price           :float            not null
#  updated_at      :datetime         not null
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
    price { rand(100.00) }
    catalog_item { build(:catalog_item, :with_access) }
  end
end
