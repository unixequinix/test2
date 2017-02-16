# == Schema Information
#
# Table name: products
#
#  description :string
#  is_alcohol  :boolean          default(FALSE)
#  name        :string
#  vat         :float            default(0.0)
#
# Indexes
#
#  index_products_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_ab0be0bcf2  (event_id => events.id)
#

class Product < ActiveRecord::Base
  belongs_to :event
  has_many :station_products, dependent: :destroy
  has_many :sale_items, dependent: :restrict_with_error

  validates :name, :event_id, presence: true
  validates :name, uniqueness: { scope: :event_id, case_sensitive: false }
end
