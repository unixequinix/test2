# == Schema Information
#
# Table name: ticket_types
#
#  id             :integer          not null, primary key
#  entitlement_id :integer
#  name           :string
#  company        :string
#  credit         :decimal(8, 2)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TicketType < ActiveRecord::Base

  # Associations
  belongs_to :entitlement

  # Validations
  validates :name, :company, :credit, :entitlement, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |ticket_type| [ticket_type.name, ticket_type.id] }
  end
end
