# == Schema Information
#
# Table name: station_products
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  price      :float            not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

class StationProduct < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order("position ASC") }

  belongs_to :product
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :price, presence: true
  validates_numericality_of :price
end
