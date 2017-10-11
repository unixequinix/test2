class Transactions::PostProcessor < ApplicationJob
  include TransactionsHelper

  queue_as :medium

  def perform(atts)
    transaction = Transaction.find(atts[:transaction_id])

    gtag = create_gtag(transaction.customer_tag_uid, transaction.event_id)
    Transactions::Credential::TicketValidator.perform_later(atts) if atts[:action].eql?("ticket_validation")
    return if gtag.blank?

    customer_id = apply_customers(transaction.event, transaction.customer_id, gtag)
    transaction.update!(gtag_id: gtag.id, customer_id: customer_id)

    return if transaction.status_not_ok?

    atts[:gtag_id] = gtag.id
    Transactions::Base.execute_descendants(atts)
  end
end
