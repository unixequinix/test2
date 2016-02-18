class MonetaryTransactionCreator
  def initialize(attributes)
    @monetary_transaction = MonetaryTransaction.new(
      customer_event_profile: attributes[:customer_event_profile],
      payment_method: attributes[:payment_method],
      transaction_source: attributes[:transaction_source],
      value_credit: credit_value(attributes[:customer_event_profile].event),
      amount: attributes[:amount],
      refundable_amount: attributes[:amount]
    )
  end

  def save
    calculate_balances
    @monetary_transaction.save if @monetary_transaction.valid?
  end

  def calculate_balances
    balances = MonetaryTransaction
               .select("sum(amount) as final_balance,
                        sum(refundable_amount) as final_refundable_balance")
               .where(customer_event_profile: @monetary_transaction.customer_event_profile)[0]
    @monetary_transaction.final_balance =
      balances.final_balance.to_i + @monetary_transaction.amount
    @monetary_transaction.final_refundable_balance =
      balances.final_refundable_balance.to_i + @monetary_transaction.refundable_amount
  end

  def credit_value(event)
    event.standard_credit_price
  end
end
