# == Schema Information
#
# Table name: entitlements
#
#  created_at      :datetime         not null
#  memory_length   :integer          default(1)
#  memory_position :integer          not null
#  mode            :string           default("counter")
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_entitlements_on_access_id  (access_id)
#  index_entitlements_on_event_id   (event_id)
#
# Foreign Keys
#
#  fk_rails_dcf903a298  (event_id => events.id)
#

class Entitlement < ActiveRecord::Base
  belongs_to :access
  belongs_to :event
  before_validation :save_memory_position
  after_destroy :destroy_memory_position
  validate :validate_memory_position
  validates :memory_length, :mode, presence: true

  # Modes
  COUNTER = "counter".freeze
  PERMANENT = "permanent".freeze
  PERMANENT_STRICT = "permanent_strict".freeze

  MODES = [COUNTER, PERMANENT, PERMANENT_STRICT].freeze
  ALL_PERMANENT = [PERMANENT, PERMANENT_STRICT].freeze

  def infinite?
    mode == PERMANENT || mode == PERMANENT_STRICT
  end

  def counter?
    mode == COUNTER
  end

  private

  def save_memory_position
    last_element = event.entitlements.order("memory_position DESC").first
    if id.nil?
      new_position = last_element.blank? ? 1 : last_element.memory_position + last_element.memory_length
      self.memory_position = new_position
    else
      step = memory_length - memory_position_was
      return change_memory_position(step) if (last_element&.memory_position).to_i + step <= limit
      errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
    end
  end

  def validate_memory_position
    return if memory_position + memory_length <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end

  def destroy_memory_position
    change_memory_position(-memory_length)
  end

  def change_memory_position(step)
    event.entitlements.where("memory_position > ?", memory_position)
         .find_each { |e| e.increment!(:memory_position, step) }
  end

  def limit
    gtag_type = event.gtag_settings["gtag_type"].to_sym
    Gtag::DEFINITIONS[gtag_type][:entitlement_limit]
  end
end
