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
  has_many :packs, through: :pack_catalog_items
  has_many :station_catalog_items, dependent: :restrict_with_error
  has_many :order_items
  has_many :orders, through: :order_items, class_name: "Order"
  has_one :credential_type

  validates :name, :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true

  scope :only_credentiables, lambda {
    combination = where(catalogable_type: CatalogItem::CREDENTIABLE_TYPES) +
                  where(catalogable_type: "Pack", catalogable_id: Pack.credentiable_packs)
    combination.uniq
  }

  scope :with_prices, lambda { |event|
    joins(:station_catalog_items, station_catalog_items: :station_parameter)
      .select("catalog_items.*, station_catalog_items.price")
      .where(station_parameters:
                      { id: StationParameter.joins(:station)
                                            .where(stations: { event_id: event,
                                                               category: "customer_porta;" }) })
  }

  # Credentiable Types
  CREDIT = "Credit".freeze
  ACCESS = "Access".freeze
  VOUCHER = "Voucher".freeze

  CREDENTIABLE_TYPES = [CREDIT, ACCESS, VOUCHER].freeze

  def price
    parameters = StationParameter.joins(:station).where(stations: { event_id: event, category: "customer_portal" })
    items = station_catalog_items.joins(:station_parameter)
                                 .select("station_catalog_items.price")
                                 .where(station_parameters: { id: parameters })
    items&.first&.price
  end

  def self.sorted
    Sorters::CatalogItemSorter.new(all).sort(format: :list)
  end

  def self.hash_sorted
    Sorters::CatalogItemSorter.new(all).sort(format: :hash)
  end
end
