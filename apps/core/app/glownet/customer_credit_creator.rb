class CustomerCreditCreator
  attr_reader :customer_credit

  def initialize(attributes)
    @customer_credit = CustomerCredit.new(
      customer_event_profile: attributes[:customer_event_profile],
      payment_method: attributes[:payment_method],
      credit_value: get_credit_value(attributes[:customer_event_profile].event),
      transaction_origin: attributes[:transaction_origin],
      amount: attributes[:amount],
      refundable_amount: attributes[:amount]
    )
  end

  def save
    calculate_balances
    @customer_credit.save if @customer_credit.valid?
  end

  def calculate_balances
    balances = CustomerCredit
               .select("sum(amount) as final_balance,
                        sum(refundable_amount) as final_refundable_balance")
               .where(customer_event_profile: @customer_credit.customer_event_profile)[0]
    @customer_credit.final_balance =
      balances.final_balance.to_i + @customer_credit.amount
    @customer_credit.final_refundable_balance =
      balances.final_refundable_balance.to_i + @customer_credit.refundable_amount
  end

  def get_credit_value(event)
    event.standard_credit_price
  end
end
