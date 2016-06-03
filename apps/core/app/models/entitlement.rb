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
  before_validation :position
  after_destroy :position_after_destroy
  validate :valid_position
  validates :memory_length, :mode, presence: true

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

  def position
    Entitlement::PositionManager.new(self).start(action: :save)
  end

  def position_after_destroy
    Entitlement::PositionManager.new(self).start(action: :destroy)
  end

  def valid_position
    Entitlement::PositionManager.new(self).start(action: :validate)
  end
end
