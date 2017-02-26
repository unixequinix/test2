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
