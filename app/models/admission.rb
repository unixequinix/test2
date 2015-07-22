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
  default_scope { order(created_at: :desc) }
  # Associations
  belongs_to :customer
  belongs_to :ticket

  # Validations
  validates :customer, :ticket, :aasm_state, presence: true
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

  def customer
    Customer.unscoped { super }
  end
end
