class Access < CatalogItem
  COUNTER = "counter".freeze
  PERMANENT = "permanent".freeze
  PERMANENT_STRICT = "permanent_strict".freeze

  MODES = [COUNTER, PERMANENT, PERMANENT_STRICT].freeze

  has_many :access_transactions, dependent: :destroy
  has_many :access_control_gates, dependent: :destroy

  before_create :set_memory, :validate_memory_position
  after_update :recalculate_all_positions, if: (-> { saved_change_to_mode? })

  validates :mode, presence: true
  validates :mode, inclusion: { in: MODES, message: "Has to be one of: #{MODES.to_sentence}" }
  validate :validate_all_positions, if: (-> { mode_changed? })

  scope(:infinite, -> { where(mode: [PERMANENT, PERMANENT_STRICT]) })

  def infinite?
    mode == PERMANENT || mode == PERMANENT_STRICT
  end

  def counter?
    mode == COUNTER
  end

  def set_memory
    accesses = id.present? ? event.accesses.where("id < ?", id) : event.accesses

    self.memory_position = accesses.sum(:memory_length) + 1
    self.memory_length = calculate_memory_length
  end

  protected

  def calculate_memory_length
    counter? ? 2 : 1
  end

  def recalculate_all_positions
    accesses = event.accesses
    accesses.update_all(memory_position: nil)
    accesses.each do |access|
      access.set_memory
      access.save!
    end
  end

  def validate_all_positions
    new_length = event.accesses.where.not(id: id).sum(:memory_length) + calculate_memory_length
    errors.add(:mode, "exceeds space limit in wristband") if new_length >= Gtag::DEFINITIONS[event.gtag_type.to_sym][:entitlement_limit]
  end

  def validate_memory_position
    errors.add(:memory_position, "You reached the maximum allowed accesses") if memory_position.to_i + memory_length.to_i >= Gtag::DEFINITIONS[event.gtag_type.to_sym][:entitlement_limit]
  end
end
