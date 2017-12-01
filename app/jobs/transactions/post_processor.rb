class Transactions::PostProcessor < ApplicationJob
  include TransactionsHelper

  queue_as :medium

  def perform(atts)
    transaction = Transaction.find(atts[:transaction_id])

    # ticket validation is special, there is no gtag at all. So we deal with it here and return.
    Transactions::Credential::TicketValidator.perform_later(atts) && return if transaction.action.eql?("ticket_validation")

    assign_resources(transaction)

    return if transaction.status_not_ok?
    Transactions::Base.execute_descendants(atts)
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

    message = "PROFILE FRAUD: customers #{customers.map(&:id).to_sentence} not the same in transaction #{transaction.id}"
    Alert.propagate(event, transaction, message) && return unless customers_ok

    Customer.claim(event, customers.select(&:registered?).first, customers.select(&:anonymous?)) || event.customers.create!
  end

  def decode_ticket(code, event)
    return unless code
    # Ticket is not found. perhaps is new sonar ticket?
    id = SonarDecoder.valid_code?(code) && SonarDecoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.ticket_types.find_by(company_code: id)

    begin
      ticket = event.tickets.find_or_create_by(code: code, ticket_type: ctt)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    ticket
  end
end
