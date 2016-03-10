class CustomerCreditTicketCreator
  attr_reader :customer_credit

  def assign(ticket)
    @customer_credit = CustomerCredit.new(
      customer_event_profile: ticket.assigned_customer_event_profile,
      transaction_origin: CustomerCredit::TICKET_ASSIGNMENT,
      payment_method: "none",
      credit_value: get_credit_value(ticket.assigned_customer_event_profile.event),
      amount: ticket.credits,
      refundable_amount: ticket.credits
    )
    calculate_balances
    @customer_credit.save if @customer_credit.valid?
  end

  def unassign(ticket)
    @customer_credit = CustomerCredit.new(
      customer_event_profile: ticket.assigned_customer_event_profile,
      transaction_origin: CustomerCredit::TICKET_UNASSIGNMENT,
      payment_method: "none",
      credit_value: get_credit_value(ticket.assigned_customer_event_profile.event),
      amount: -ticket.credits,
      refundable_amount: -ticket.credits
    )
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

