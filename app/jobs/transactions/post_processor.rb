class Transactions::PostProcessor < ApplicationJob
  include TransactionsHelper

  queue_as :medium

  def perform(transaction)
    gtag = create_gtag(transaction.customer_tag_uid, transaction.event_id)
    return unless gtag

    customer_id = apply_customers(transaction.event_id, transaction.customer_id, gtag)
    transaction.update!(gtag_id: gtag.id, customer_id: customer_id)
  end

  def apply_customers(event_id, customer_id, gtag)
    claimed = Customer.claim(event_id, customer_id, gtag.customer_id)
    return customer_id if claimed.present?

    gtag.update!(customer_id: customer_id) if customer_id.present?
    gtag.update!(customer_id: Customer.create!(event_id: event_id, anonymous: true).id) if gtag.customer_id.blank?
    gtag.customer_id
  end
end
