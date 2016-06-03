# == Schema Information
#
# Table name: station_catalog_items
#
#  id              :integer          not null, primary key
#  catalog_item_id :integer          not null
#  price           :float            not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class StationCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :catalog_item
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :price, presence: true
  validates_numericality_of :price
end
