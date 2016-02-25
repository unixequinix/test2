# == Schema Information
#
# Table name: station_catalog_items
#
#  id              :integer          not null, primary key
#  station_id      :integer          not null
#  catalog_item_id :integer          not null
#  price           :float            not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class StationCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  has_one :catalog_item
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :price, presence: true
end
