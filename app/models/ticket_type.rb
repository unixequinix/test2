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
#  deleted_at :datetime
#

class TicketType < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_many :entitlement_ticket_types, dependent: :restrict_with_error
  has_many :entitlements, through: :entitlement_ticket_types, dependent: :restrict_with_error

  accepts_nested_attributes_for :entitlements

  # Validations
  validates :name, :company, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |ticket_type| [ticket_type.name, ticket_type.id] }
  end

end
