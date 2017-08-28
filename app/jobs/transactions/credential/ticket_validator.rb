class Transactions::Credential::TicketValidator < ApplicationJob
  queue_as :low

  def perform(atts)
    transaction = CredentialTransaction.find(atts[:transaction_id])
    event = transaction.event
    ticket = event.tickets.find_by(code: transaction.ticket_code)

    ticket.update!(customer: Customer.create!(event: event)) if ticket.customer_id.blank?
    ticket.redeemed? ? Alert.propagate(t.event, "has been redeemed twice", :high, ticket) : ticket.update!(redeemed: true)
  end
end
