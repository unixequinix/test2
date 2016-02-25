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

  belongs_to :station
  belongs_to :catalog_item
  has_many :station_parameters, as: :station_parametable, dependent: :destroy

  validates :price, presence: true
end
