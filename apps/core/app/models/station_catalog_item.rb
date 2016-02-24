class StationCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :station
  belongs_to :catalog_item
  has_many :station_parameters, as: :station_parametable, dependent: :destroy

  validates :price, presence: true
end
