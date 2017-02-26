class StationProduct < ActiveRecord::Base
  attr_accessor :product_name

  default_scope { order("position ASC") }

  belongs_to :product
  belongs_to :station, touch: true

  validates :price, :product_id, :position, presence: true
  validates :price, numericality: true
  validates :product_id, uniqueness: { scope: :station_id }

  before_validation :set_position

  def self.policy_class
    StationItemPolicy
  end

  def self.sort_column
    :position
  end

  private

  def set_position
    self.position = station.station_products.count + 1 if position.blank?
  end
end
