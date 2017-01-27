# == Schema Information
#
# Table name: station_products
#
#  position   :integer
#  price      :float            not null
#
# Indexes
#
#  index_station_products_on_product_id  (product_id)
#  index_station_products_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_b1a69cdc0c  (product_id => products.id)
#  fk_rails_d96ed1200f  (station_id => stations.id)
#

class StationProduct < ActiveRecord::Base
  default_scope { order("position ASC") }

  belongs_to :product
  belongs_to :station, touch: true

  validates :price, :product_id, presence: true
  validates :price, numericality: true
  validates :product_id, uniqueness: { scope: :station_id }

  def self.policy_class
    StationItemPolicy
  end
end
