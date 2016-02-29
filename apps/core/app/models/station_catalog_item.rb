# == Schema Information
#
# Table name: station_catalog_items
#
#  id              :integer          not null, primary key
#  catalog_item_id :integer          not null
#  price           :float            not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class StationCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :catalog_item
  has_one :station_parameter, as: :station_parametable, dependent: :destroy
  accepts_nested_attributes_for :station_parameter, allow_destroy: true

  validates :price, presence: true

  def self.catalog_items_sortered
    catalog_items_hash_sorted.values.flatten
  end

  def self.catalog_items_hash_sorted
    catalog_items.reduce(Hash[keys_sortered.map { |key| [key, []] }]) do |acum, catalog_item|
      acum[catalog_item.catalogable_type] << catalog_item
      acum
    end
  end

  def self.keys_sortered
    %w(Credit Voucher Access Pack)
  end
end
