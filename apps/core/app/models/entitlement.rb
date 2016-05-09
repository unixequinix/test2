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

  LENGTH = [1, 2]

  # Modes
  COUNTER = "counter"
  PERMANENT = "permanent"
  PERMANENT_STRICT = "permanent_strict"

  MODES = [COUNTER, PERMANENT, PERMANENT_STRICT]

  def infinite?
    mode == PERMANENT || mode == PERMANENT_STRICT
  end

  private

  def set_memory_position
    id.nil? ? create_new_position : calculate_memory_position_after_update
  end

  def create_new_position
    self.memory_position = last_position
  end

  def last_position
    last_element.present? ? last_element.memory_position + last_element.memory_length : 1
  end

  def last_element
    Entitlement.where(event_id: event_id).order("memory_position DESC").first
  end

  def calculate_memory_position_after_update
    previous_length = Entitlement.find(id).memory_length
    step = memory_length - previous_length
    return increment_memory_position(step) if last_element.memory_position + step <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end

  def calculate_memory_position_after_destroy
    increment_memory_position(-memory_length)
  end

  def increment_memory_position(step)
    Entitlement.where(event_id: event_id)
      .where("memory_position > ?", memory_position)
      .each { |entitlement| entitlement.increment!(:memory_position, step) }
  end

  def valid_position?
    return if memory_position + memory_length <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end

  def limit
    Gtag.field_by_name(name: gtag_type, field: :entitlement_limit)
  end

  def gtag_type
    event.get_parameter("gtag", "form", "gtag_type")
  end
end
