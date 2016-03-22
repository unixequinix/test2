# == Schema Information
#
# Table name: credential_types
#
#  id              :integer          not null, primary key
#  catalog_item_id :integer          not null
#  memory_position :integer          not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CredentialType < ActiveRecord::Base
  acts_as_paranoid
  before_validation :set_memory_position
  after_destroy :calculate_memory_position

  belongs_to :catalog_item
  has_many :company_ticket_types

  # Validations
  validates :catalog_item, presence: true
  validate :valid_position

  def credits
    catalog_item.catalogable_type == "Pack" ? catalog_item.catalogable.credits : []
  end

  private

  def set_memory_position
    self.memory_position = last_position + 1 if id.nil?
  end

  def last_position
    CredentialType.joins(:catalog_item)
      .where(catalog_items: { event_id: catalog_item.event_id })
      .order("memory_position DESC")
      .first.try(:memory_position) || 0
  end

  def calculate_memory_position
    CredentialType.joins(:catalog_item)
      .where(catalog_items: { event_id: catalog_item.event_id })
      .where("memory_position > ?", memory_position)
      .each { |ct| CredentialType.decrement_counter(:memory_position, ct.id) }
  end

  def valid_position
    limit = Gtag.field_by_name(name: gtag_type, field: :credential_limit)
    return if self.memory_position <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_credential")
  end

  def gtag_type
    EventParameter.joins(:parameter)
                  .find_by(parameters: { name: "gtag_type" }, event_id: catalog_item.event_id).value
  end
end
