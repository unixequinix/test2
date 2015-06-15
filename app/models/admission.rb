# == Schema Information
#
# Table name: admissions
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  ticket_id   :integer          not null
#  aasm_state  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Admission < ActiveRecord::Base
  # Associations
  belongs_to :customer
  belongs_to :event

  # Validations
  validates :customer, :event, presence: true
end
