# == Schema Information
#
# Table name: entitlements
#
#  id                   :integer          not null, primary key
#  entitlementable_id   :integer          not null
#  entitlementable_type :string           not null
#  event_id             :integer          not null
#  memory_position      :integer          not null
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  memory_length        :integer          default(1)
#  mode                 :string           default("counter")
#

class Entitlement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :entitlementable, polymorphic: true, touch: true
  belongs_to :access, -> { where(entitlement: { entitlementable_type: "Access" }) },
             foreign_key: "entitlementable_id"
  belongs_to :event
  before_validation :set_memory_position
  validates :memory_length, :mode, presence: true
  validate :valid_position?

  after_destroy :calculate_memory_position_after_destroy

  LENGTH = [1, 2].freeze

  # Modes
  COUNTER = "counter".freeze
  PERMANENT = "permanent".freeze
  PERMANENT_STRICT = "permanent_strict".freeze

  MODES = [COUNTER, PERMANENT, PERMANENT_STRICT].freeze

  def infinite?
    mode == PERMANENT || mode == PERMANENT_STRICT
  end

  private

  def set_memory_position
    if id.nil?
      self.memory_position = Entitlement::PositionCreator.new(self).create_new_position
    else
      Entitlement::PositionUpdater.new(self).calculate_memory_position_after_update
    end
  end

  def calculate_memory_position_after_destroy
    Entitlement::PositionUpdater.new(self).calculate_memory_position_after_destroy
  end

  def valid_position?
    return if memory_position + memory_length <= Entitlement::PositionManager.new(self).limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end
end
