class Product < ActiveRecord::Base
  belongs_to :event
  has_many :station_products, dependent: :destroy
  has_many :sale_items, dependent: :restrict_with_error

  validates :name, :event_id, presence: true
  validates :name, uniqueness: { scope: :event_id, case_sensitive: false }
end
