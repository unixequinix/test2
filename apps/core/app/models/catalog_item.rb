# == Schema Information
#
# Table name: catalog_items
#
#  id               :integer          not null, primary key
#  event_id         :integer          not null
#  catalogable_id   :integer          not null
#  catalogable_type :string           not null
#  name             :string
#  description      :text
#  initial_amount   :integer
#  step             :integer
#  max_purchasable  :integer
#  min_purchasable  :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :event
  belongs_to :catalogable, polymorphic: true, touch: true
  has_many :pack_catalog_items, dependent: :restrict_with_error
  has_one :credential_type
  has_many :station_catalog_items, dependent: :restrict_with_error

  validates :name, :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true

  scope :only_credentiables, lambda {
    combination = where(catalogable_type: CatalogItem::CREDENTIABLE_TYPES).includes(:credential_type) +
                  where(catalogable_type: "Pack", catalogable_id: Pack.credentiable_packs).includes(:credential_type)
    combination.uniq.reduce([]) do |a, it|
      a << it if it.credential_type.blank?
      a
    end
  }

  # Credentiable Types
  CREDIT = "Credit"
  ACCESS = "Access"
  VOUCHER = "Voucher"

  CREDENTIABLE_TYPES = [CREDIT, ACCESS, VOUCHER]
end
