class Product < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_one :catalog_item, as: :catalogable, dependent: :destroy
  accepts_nested_attributes_for :catalog_item, allow_destroy: true
  has_and_belongs_to_many :vouchers

  # Validations
  validates :catalog_item, presence: true
end
