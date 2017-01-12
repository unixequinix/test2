# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer          default(1)
#  memory_position :integer
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

class CatalogItem < ActiveRecord::Base
  belongs_to :event
  has_many :pack_catalog_items, dependent: :destroy
  has_many :packs, through: :pack_catalog_items
  has_many :station_catalog_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :ticket_types, dependent: :nullify
  has_many :transactions

  validates :name, presence: true
  validates :step, numericality: { greater_than: 0 }

  scope :accesses, -> { where(type: "Access") }
  scope :credits, -> { where(type: "Credit") }
  scope :packs, -> { where(type: "Pack") }
  scope :not_packs, -> { where.not(type: "Pack") }
  scope :user_flags, -> { where(type: "UserFlag") }
  scope :not_user_flags, -> { where.not(type: "UserFlag") }

  scope :only_credentiables, -> { (where(type: CREDENTIABLE_TYPES) + where(type: "Pack", id: Pack.credentiable_packs)).uniq }

  # Credentiable Types
  CREDIT = "Credit".freeze
  ACCESS = "Access".freeze

  CREDENTIABLE_TYPES = [CREDIT, ACCESS].freeze

  def all_catalog_items
    is_a?(Pack) ? catalog_items : [self]
  end

  def credits
    0
  end

  def price
    station_catalog_items.find_by(station: event.portal_station)&.price
  end
end
