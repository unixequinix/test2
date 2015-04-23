# == Schema Information
#
# Table name: entitlement_ticket_types
#
#  id             :integer          not null, primary key
#  entitlement_id :integer          not null
#  ticket_type_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class EntitlementTicketType < ActiveRecord::Base
  belongs_to :entitlement
  belongs_to :ticket_type

  # Validations
  validates :entitlement, :ticket_type, presence: true
end
