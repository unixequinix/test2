class StationCatalogItem < ApplicationRecord
  belongs_to :catalog_item
  belongs_to :station, touch: true

  validates :price, presence: true
  validates :price, numericality: true
  validates :catalog_item_id, presence: true

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :price
  end
end
