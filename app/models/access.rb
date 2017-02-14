# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer          default(1)
#  memory_position :integer          indexed => [event_id]
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id                      (event_id)
#  index_catalog_items_on_memory_position_and_event_id  (memory_position,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

class Access < CatalogItem
  has_many :access_transactions, dependent: :destroy
  has_many :access_control_gates, dependent: :destroy

  before_validation :set_infinite_values, if: :infinite?
  before_validation :set_memory_length
  before_validation :calculate_memory_position

  validates :memory_length, :mode, presence: true
  validates :initial_amount, :step, :max_purchasable, :min_purchasable, presence: true
  validates :max_purchasable, numericality: { less_than: 128 }

  validate :validate_memory_position
  validate :min_below_max

  scope :infinite, -> { where(mode: [PERMANENT, PERMANENT_STRICT]) }

  COUNTER = "counter".freeze
  PERMANENT = "permanent".freeze
  PERMANENT_STRICT = "permanent_strict".freeze

  MODES = [COUNTER, PERMANENT, PERMANENT_STRICT].freeze

  def infinite?
    mode == PERMANENT || mode == PERMANENT_STRICT
  end

  def counter?
    mode == COUNTER
  end

  def set_infinite_values
    self.min_purchasable = 0
    self.max_purchasable = 1
    self.step = 1
    self.initial_amount = 0
  end

  def set_memory_length
    self.memory_length = 2 if max_purchasable.to_i > 7
  end

  def min_below_max
    return if min_purchasable.to_i <= max_purchasable.to_i
    errors[:min_purchasable] << I18n.t("errors.messages.greater_than_maximum")
  end

  def calculate_memory_position
    return if memory_position.present?
    last_access = event.catalog_items.accesses.order(:memory_position).last
    new_position = last_access.present? ? last_access.memory_position.to_i + last_access.memory_length.to_i : 1
    self.memory_position = new_position
  end

  def validate_memory_position
    return if memory_position.to_i + memory_length.to_i <= Gtag::DEFINITIONS[event.gtag_type.to_sym][:entitlement_limit]
    errors.add(:memory_position, "You reached the maximun allowed accesses")
  end
end
