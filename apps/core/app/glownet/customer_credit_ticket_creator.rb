# TODO: look at this and make sure it works
class CustomerCreditTicketCreator < CustomerCreditCreator
  def assign(ticket)
    loop_credits(ticket, CustomerCredit::TICKET_ASSIGNMENT, 1)
  end

  def unassign(ticket)
    loop_credits(ticket, CustomerCredit::TICKET_UNASSIGNMENT, -1)
  end

  def loop_credits(ticket, origin, sign = 1)
    ticket.credits.each do |credit|
      params = { amount: (credit.total_amount * sign),
                 transaction_origin: origin,
                 credit_value: credit.value,
                 refundable_amount: (credit.total_amount * sign),
                 transaction_type: "ticket_credit"
               }
      create_credit(ticket.assigned_profile, params)
    end
  end
end
