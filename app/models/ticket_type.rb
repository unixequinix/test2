# == Schema Information
#
# Table name: ticket_types
#
#  id         :integer          not null, primary key
#  name       :string
#  company    :string
#  credit     :decimal(8, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TicketType < ActiveRecord::Base

  # Associations
  has_many :entitlement_ticket_types
  has_many :entitlements, through: :entitlement_ticket_types

  # Validations
  validates :name, :company, :credit, :entitlements, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |ticket_type| [ticket_type.name, ticket_type.id] }
  end
end
