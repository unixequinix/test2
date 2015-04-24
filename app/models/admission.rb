# == Schema Information
#
# Table name: admissions
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  ticket_id   :integer          not null
#  credit      :decimal(8, 2)
#  aasm_state  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Admission < ActiveRecord::Base

  # Associations
  belongs_to :customer
  belongs_to :ticket

  # Validations
  validates :customer, :ticket, :aasm_state, presence: true

  # State machine
  include AASM

  aasm do
    state :assigned, initial: true
    state :unassigned

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

end
