class StationProduct < ApplicationRecord
  attr_accessor :product_name

  default_scope { order(position: :asc) }

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

  def product_validations
    errors.add(:product_name, :blank) if product_name.blank?
    errors.add(:product_name, "Already present") if product_name && station.station_products.pluck(:product_id).include?(product_id)
  end

  private

  def set_position
    self.position = station.station_products.count + 1 if position.blank?
  end
end
