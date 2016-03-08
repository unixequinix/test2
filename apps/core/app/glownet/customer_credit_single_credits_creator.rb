class CustomerCreditSingleCreditsCreator < CustomerCreditCreator
  attr_reader :customer_credit

  def initialize(attributes)
    @order_item =  attributes[:order_item]
    @customer_credit = CustomerCredit.new(
      customer_event_profile: attributes[:customer_event_profile],
      transaction_origin: attributes[:transaction_origin],
      payment_method: attributes[:payment_method],
      credit_value: get_credit_value(attributes[:customer_event_profile].event),
      amount: @order_item.credits_included,
      refundable_amount: calculate_refundable_amount(attributes[:customer_event_profile].event)
    )
  end

  def calculate_refundable_amount(_event)
    0
  end

  def get_credit_value(event)
    event.standard_credit_price
  end
end
