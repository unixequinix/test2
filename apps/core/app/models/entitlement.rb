# == Schema Information
#
# Table name: entitlements
#
#  id                   :integer          not null, primary key
#  entitlementable_id   :integer          not null
#  entitlementable_type :string           not null
#  event_id             :integer          not null
#  memory_position      :integer          not null
#  memory_length        :string           default("simple"), not null
#  infinite             :boolean          default(FALSE), not null
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Entitlement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :entitlementable, polymorphic: true, touch: true
  belongs_to :access, -> { where(entitlement: { entitlementable_type: "Access" }) },
             foreign_key: "entitlementable_id"
  belongs_to :event
  before_save :set_memory_position
  validates :memory_length, presence: true
  validates_inclusion_of :infinite, in: [true, false]

  after_destroy :calculate_memory_position

  # Service Types
  SIMPLE = "simple"
  DOUBLE = "double"

  TYPES = [SIMPLE, DOUBLE]
  SHIFT = { "simple" => 1, "double" => 2 }

  def set_memory_position
    self.memory_position = last_position if id.nil?
  end

  def last_position
    last_entitlement = Entitlement.where(event_id: event_id).order("memory_position DESC").first
    last_entitlement.present? ? last_entitlement.memory_position + SHIFT[last_entitlement.memory_length] : 1
 end

  def calculate_memory_position
    Entitlement.where(event_id: event_id)
      .where("memory_position > ?", memory_position)
      .each { |entitlement| entitlement.decrement!(:memory_position, SHIFT[memory_length]) }
  end
end
