# == Schema Information
#
# Table name: tickets
#
#  id             :integer          not null, primary key
#  ticket_type_id :integer
#  number         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Ticket < ActiveRecord::Base

  # Associations
  has_many :admissions
  has_many :customer, through: :admissions
  belongs_to :ticket_type

  # Validations
  validates :number, presence: true

end
