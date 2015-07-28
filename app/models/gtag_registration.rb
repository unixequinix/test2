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
  default_scope { order(created_at: :desc) }

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

  def refundable_amount
    # TODO Get event from relation
    current_event = Event.find(1)
    standard_credit_price = current_event.standard_credit.online_product.rounded_price
    self.gtag.gtag_credit_log.amount * standard_credit_price
  end

  def refundable_amount_after_fee
    # TODO Get event from relation
    current_event = Event.find(1)
    fee = EventParameter.find_by(event_id: current_event.id, parameter_id: Parameter.find_by(category: 'refund', group: current_event.refund_service, name: 'fee')).value
    refundable_amount - fee.to_f
  end

  def refundable?
    # TODO Get event from relation
    current_event = Event.find(1)
    minimum = EventParameter.find_by(event_id: Event.find(1).id, parameter_id: Parameter.find_by(category: 'refund', group: current_event.refund_service, name: 'minimum')).value
    !self.gtag.gtag_credit_log.nil? && (refundable_amount_after_fee >= minimum.to_f)
  end

  def customer
    Customer.unscoped { super }
  end

end
