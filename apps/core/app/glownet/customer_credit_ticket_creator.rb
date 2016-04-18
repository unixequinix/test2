class CustomerCreditTicketCreator < CustomerCreditCreator
  def assign(ticket)
    create_customer_credit(ticket, CustomerCredit::TICKET_ASSIGNMENT, 1)
  end

  def unassign(ticket)
    create_customer_credit(ticket, CustomerCredit::TICKET_UNASSIGNMENT, -1)
  end

  def create_customer_credit(ticket, origin, multiplier)
    ticket.credits.each do |credit_item|
      CustomerCredit.create(
        customer_event_profile: ticket.assigned_customer_event_profile,
        transaction_origin: origin,
        payment_method: "none",
        credit_value: credit_item.value,
        amount: credit_item.total_amount * multiplier,
        refundable_amount: credit_item.total_amount * multiplier
      )
    end
  end
end
