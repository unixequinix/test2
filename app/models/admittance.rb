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
