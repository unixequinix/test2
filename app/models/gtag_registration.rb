# == Schema Information
#
# Table name: gtag_registrations
#
#  id                        :integer          not null, primary key
#  gtag_id                   :integer          not null
#  aasm_state                :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer          default(1), not null
#

class GtagRegistration < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :customer_event_profile
  belongs_to :gtag

  # Validations
  validates :customer_event_profile, :gtag, :aasm_state, presence: true
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

  def refundable_amount
    # TODO Get event from relation
    current_event = Event.find(1)
    standard_credit_price = current_event.standard_credit.online_product.rounded_price
    credit_amount = 0
    credit_amount = self.gtag.gtag_credit_log.amount unless self.gtag.gtag_credit_log.nil?
    credit_amount * standard_credit_price
  end

  def refundable_amount_after_fee
    # TODO Get event from relation
    current_event = Event.find(1)
    fee = current_event.get_parameter('refund', current_event.refund_service, 'fee')
    refundable_amount - fee.to_f
  end

  def refundable?
    # TODO Get event from relation
    current_event = Event.find(1)
    minimum = current_event.get_parameter('refund', current_event.refund_service, 'minimum')
    !self.gtag.gtag_credit_log.nil? && (refundable_amount_after_fee >= minimum.to_f && refundable_amount_after_fee >= 0)
  end

  def customer_event_profile
    CustomerEventProfile.unscoped { super }
  end

end
