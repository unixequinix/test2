class CatalogItem < ApplicationRecord
  belongs_to :event
  belongs_to :station, optional: true

  has_many :station_catalog_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items, dependent: :destroy
  has_many :ticket_types, dependent: :nullify
  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id, case_sensitive: false }
  validates :symbol, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1, maximum: 3 }

  before_destroy :check_for_event_state

  scope :accesses, -> { where(type: "Access") }
  scope :operator_permissions, -> { where(type: "OperatorPermission") }
  scope :currencies, -> { where(type: %w[Credit VirtualCredit Token]) }
  scope :credits, -> { where(type: %w[Credit VirtualCredit]) }
  scope :not_currencies, -> { where.not(type: %w[Credit VirtualCredit Token]) }
  scope :packs, -> { where(type: "Pack") }
  scope :not_packs, -> { where.not(type: "Pack") }
  scope :user_flags, -> { where(type: "UserFlag") }
  scope :not_user_flags, -> { where.not(type: "UserFlag") }

  scope(:only_credentiables, -> { (where(type: CREDENTIABLE_TYPES) + where(type: "Pack", id: Pack.credentiable_packs)).uniq })

  # Credentiable Types
  CREDIT = "Credit".freeze
  ACCESS = "Access".freeze

  CREDENTIABLE_TYPES = [CREDIT, ACCESS].freeze

  def description
    "#{type} #{name}"
  end

  def all_catalog_items
    is_a?(Pack) ? catalog_items : [self]
  end

  def credits
    0
  end

  def virtual_credits
    0
  end

  def tokens
    0
  end

  private

  def check_for_event_state
    return unless %w[Credit VirtualCredit Token].include?(type)
    return if event.created?

    errors[:base] << "cannot delete currency during event"
    throw :abort
  end
end
