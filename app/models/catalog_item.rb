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

  scope(:accesses, -> { where(type: "Access") })
  scope(:operator_permissions, -> { where(type: "OperatorPermission") })
  scope(:credits, -> { where(type: "Credit").or(where(type: "VirtualCredit")) })
  scope(:packs, -> { where(type: "Pack") })
  scope(:not_packs, -> { where.not(type: "Pack") })
  scope(:user_flags, -> { where(type: "UserFlag") })
  scope(:not_user_flags, -> { where.not(type: "UserFlag") })

  scope(:only_credentiables, -> { (where(type: CREDENTIABLE_TYPES) + where(type: "Pack", id: Pack.credentiable_packs)).uniq })

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

  def virtual_credits
    0
  end
end
