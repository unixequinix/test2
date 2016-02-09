# == Schema Information
#
# Table name: credential_types
#
#  id              :integer          not null, primary key
#  memory_position :integer          not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CredentialType < ActiveRecord::Base
  acts_as_paranoid
  before_save :set_memory_position
  after_destroy :calculate_memory_position

  has_one :preevent_item, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_item, allow_destroy: true

  # Validations
  validates :preevent_item, presence: true

  private

  def set_memory_position
    self.memory_position = last_position
  end

  def last_position
    CredentialType.joins(:preevent_item)
      .where(preevent_items: { event_id: preevent_item.event_id })
      .order("memory_position DESC")
      .first.try(:memory_position).try(:+, 1) || 1
  end

  def calculate_memory_position
    CredentialType.joins(:preevent_item)
      .where(preevent_items: { event_id: preevent_item.event_id })
      .where("memory_position > ?", memory_position)
      .each { |ct| CredentialType.decrement_counter(:memory_position, ct.id) }
  end
end
