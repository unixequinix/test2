# == Schema Information
#
# Table name: gtag_registrations
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  gtag_id     :integer          not null
#  aasm_state  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class GtagRegistration < ActiveRecord::Base

  # Associations
  belongs_to :customer
  belongs_to :gtag

  # Validations
  validates :customer, :gtag, :aasm_state, presence: true
  validates_uniqueness_of :gtag, conditions: -> { where(aasm_state: :assigned) }

  # State machine
  include AASM

  aasm do
    state :assigned, initial: true
    state :unassigned

    event :unassign do
      transitions from: :assigned, to: :unassigned
    end
  end

  def refundable?
    self.gtag.gtag_credit_log.amount - 6 >= 1
  end

end
