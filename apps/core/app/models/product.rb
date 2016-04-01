# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  name        :string
#  is_alcohol  :boolean          default(FALSE)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string
#  event_id    :integer
#

class Product < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  has_and_belongs_to_many :vouchers

  validates :name, :event_id, presence: true

  scope :unassigned_products, lambda { |product|
    where("id NOT IN (
           SELECT station_products.product_id FROM station_products
           INNER JOIN station_parameters
           ON station_products.id = station_parameters.station_parametable_id
           AND station_parameters.station_parametable_type = 'StationProduct'
           WHERE station_id = #{product.id})")
  end
end
