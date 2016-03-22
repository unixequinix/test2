# == Schema Information
#
# Table name: entitlements
#
#  id                   :integer          not null, primary key
#  entitlementable_id   :integer          not null
#  entitlementable_type :string           not null
#  event_id             :integer          not null
#  memory_position      :integer          not null
#  infinite             :boolean          default(FALSE), not null
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  memory_length        :integer          default(1)
#

class Entitlement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :entitlementable, polymorphic: true, touch: true
  belongs_to :access, -> { where(entitlement: { entitlementable_type: "Access" }) },
             foreign_key: "entitlementable_id"
  belongs_to :event
  before_validation :set_memory_position
  validates :memory_length, presence: true
  validate :valid_position
  validates_inclusion_of :infinite, in: [true, false]

  after_destroy :calculate_memory_position

  # Service Types
  SIMPLE = "simple"
  DOUBLE = "double"

  TYPES = [SIMPLE, DOUBLE]

  private

  def set_memory_position
    self.memory_position = last_position if id.nil?
  end

  def last_position
    last = Entitlement.where(event_id: event_id).order("memory_position DESC").first
    last.present? ? last.memory_position + last.memory_length : 1
  end

  def calculate_memory_position
    Entitlement.where(event_id: event_id)
      .where("memory_position > ?", memory_position)
      .each { |entitlement| entitlement.decrement!(:memory_position, memory_length) }
  end

  def valid_position
    limit = Gtag.field_by_name(name: gtag_type, field: :entitlement_limit)
    return if memory_position + memory_length <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end

  def gtag_type
    "ultralight_ev1"
    #EventParameter.joins(:parameter)
    #  .find_by(parameters: { name: "gtag_type" }, event_id: catalog_item.event_id).value
  end
end
