# == Schema Information
#
# Table name: ticket_types
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  company    :string           not null
#  credit     :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TicketType < ActiveRecord::Base

  # Associations
  has_many :entitlement_ticket_types, dependent: :destroy
  has_many :entitlements, through: :entitlement_ticket_types, dependent: :destroy

  accepts_nested_attributes_for :entitlements

  # Validations
  validates :name, :company, :credit, :entitlements, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |ticket_type| [ticket_type.name, ticket_type.id] }
  end

end
