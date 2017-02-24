# == Schema Information
#
# Table name: catalog_items
#
#  memory_length   :integer          default(1)
#  memory_position :integer          indexed => [event_id]
#  mode            :string
#  name            :string
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

  before_validation :set_memory_length
  before_validation :calculate_memory_position

  validates :memory_length, :mode, presence: true
  validate :validate_memory_position

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

  def set_memory_length
    self.memory_length = 2
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
