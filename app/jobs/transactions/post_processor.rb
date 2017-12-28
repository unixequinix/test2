module Transactions
  class PostProcessor < ApplicationJob
    include TransactionsHelper

    queue_as :medium

    def perform(transaction, atts = {}) # rubocop:disable Metrics/PerceivedComplexity
      event = transaction.event
      code = transaction.ticket_code

      operator_tag = create_gtag(transaction.operator_tag_uid, event.id)
      operator = operator_tag.customer || event.customers.create!(operator: true) if operator_tag
      operator_tag&.update!(customer: operator)

      gtag = create_gtag(transaction.customer_tag_uid, event.id)
      ticket = event.tickets.find_by(code: code) || decode_ticket(code, event) if Credential::TicketChecker::TRIGGERS.include?(transaction.action)
      order = transaction.customer&.order_items&.find_by(counter: transaction.order_item_counter)&.order
      customer = resolve_customer(event, transaction, ticket, gtag, order)

      ts = { gtag: gtag, ticket: ticket, order: order, customer: customer, operator: operator, operator_gtag: operator_tag }.reject { |_, v| v.nil? }
      transaction.update!(ts)
      [ticket, gtag].map { |credential| credential&.update!(customer: customer) } if customer

      Pokes::Base.execute_descendants(transaction)

      return if transaction.status_not_ok?
      Base.descendants.each { |klass| klass.perform_later(transaction, atts) if klass::TRIGGERS.include? transaction.action }
    end

    def resolve_customer(event, transaction, ticket, gtag, order)
      customers = [transaction, ticket, gtag, order].compact.map(&:customer).compact.uniq.sort_by { |i| i.registered? ? 1 : 2 }

      if customers.count(&:registered?) > 1
        msg = "PROFILE FRAUD: customers involved #{customers.map(&:id).to_sentence} are not the same or anonymous"
        Alert.propagate(event, transaction, msg)
        return
      end

      Customer.claim(event, customers.first, customers.slice(1..-1)) || event.customers.create!
    end
  end
end
