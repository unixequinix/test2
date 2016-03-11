class CustomerCreditTicketCreator
  attr_reader :customer_credit

  def assign(ticket)
    ticket.credits.each do |credit_item|
      @customer_credit = CustomerCredit.new(
        customer_event_profile: ticket.assigned_customer_event_profile,
        transaction_origin: CustomerCredit::TICKET_ASSIGNMENT,
        payment_method: "none",
        credit_value: credit_item.catalogable.value,
        amount: credit_item.sum,
        refundable_amount: credit_item.sum
      )
      calculate_balances
      @customer_credit.save if @customer_credit.valid?
    end
  end

  def unassign(ticket)
    ticket.credits.each do |credit_item|
      @customer_credit = CustomerCredit.new(
        customer_event_profile: ticket.assigned_customer_event_profile,
        transaction_origin: CustomerCredit::TICKET_UNASSIGNMENT,
        payment_method: "none",
        credit_value: credit_item.catalogable.value,
        amount: -credit_item.sum,
        refundable_amount: -credit_item.sum
      )
      calculate_balances
      @customer_credit.save if @customer_credit.valid?
    end
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
end

