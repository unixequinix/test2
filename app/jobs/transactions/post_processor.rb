module Transactions
  class PostProcessor < ApplicationJob
    include TransactionsHelper

    queue_as :medium

    def perform(transaction, atts = {})
      assign_resources(transaction)

      return if transaction.status_not_ok?
      Base.descendants.each { |klass| klass.perform_now(transaction, atts) if klass::TRIGGERS.include? transaction.action }
      # Stats::Base.execute_descendants(atts[:transaction_id], atts[:action])
    end

    def assign_resources(transaction)
      event = transaction.event
      gtag = create_gtag(transaction.customer_tag_uid, event.id)
      ticket = event.tickets.find_by(code: transaction.ticket_code) || decode_ticket(transaction.ticket_code, event)
      order = transaction.customer&.order_items&.find_by(counter: transaction.order_item_counter)&.order
      customer = resolve_customer(event, transaction, ticket, gtag, order)

      transaction.update!({ gtag: gtag, ticket: ticket, order: order, customer: customer }.reject { |_, v| v.nil? })
      [ticket, gtag].map { |credential| credential&.update!(customer: customer) } if customer
    end

    def resolve_customer(event, transaction, ticket, gtag, order)
      customers = [transaction, ticket, gtag, order].compact.map(&:customer).compact.uniq
      customers_ok = customers.select(&:registered?).size < 2

      message = "PROFILE FRAUD IN TRANSACTION #{transaction.id}: customers involved #{customers.map(&:id).to_sentence} are not the same or anonymous"
      Alert.propagate(event, transaction, message) && return unless customers_ok

      Customer.claim(event, customers.select(&:registered?).first, customers.select(&:anonymous?)) || event.customers.create!
    end
  end
end
