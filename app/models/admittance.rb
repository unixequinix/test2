# == Schema Information
#
# Table name: admittances
#
#  id           :integer          not null, primary key
#  admission_id :integer
#  ticket_id    :integer
#  aasm_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Admittance < ActiveRecord::Base
  # Associations
  belongs_to :admission
  belongs_to :ticket

  # Validations
  validates :admission, :ticket, :aasm_state, presence: true
  validates_uniqueness_of :ticket,
    conditions: -> { where(aasm_state: :assigned) }

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
