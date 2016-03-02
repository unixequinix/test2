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
  has_many :station_catalog_items, dependent: :restrict_with_error
  has_one :credential_type

  validates :name, :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true

  scope :only_credentiables, lambda {
    combination = where(catalogable_type: CatalogItem::CREDENTIABLE_TYPES)
                  .includes(:credential_type) +
                  where(catalogable_type: "Pack", catalogable_id: Pack.credentiable_packs)
                  .includes(:credential_type)
    combination.uniq.each_with_object([]) do |it, a|
      a << it if it.credential_type.blank?
    end
  }

  # Credentiable Types
  CREDIT = "Credit"
  ACCESS = "Access"
  VOUCHER = "Voucher"

  CREDENTIABLE_TYPES = [CREDIT, ACCESS, VOUCHER]

  def self.sorted
    hash_sorted.values.flatten
  end

  def self.hash_sorted(keys_sorted)
    hash = Hash[keys_sorted.map { |key| [key, []] }]
    build_hash(hash)
    remove_empty_categories(hash)
    sort_by_price(hash)
  end

  def self.remove_empty_categories(hash)
    hash.delete_if { |_k, v| v.blank? }
  end

  def self.build_hash(hash)
    all.each_with_object(hash) do |catalog_item, acum|
      acum[catalog_item.catalogable_type] << catalog_item
    end
  end

  def self.sort_by_price(hash)
    hash.each do |_k, v|
      v.sort! { |x, y| x.price <=> y.price }
    end
  end
end
