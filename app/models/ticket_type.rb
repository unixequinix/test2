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
  has_and_belongs_to_many :entitlements

  # Validations
  validates :name, :company, :credit, presence: true
end
