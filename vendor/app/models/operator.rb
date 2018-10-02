class Operator
  attr_accessor :event

  KLASSES = { ticket: Ticket, gtag: Gtag, customer: Customer }.freeze

  def self.search(event, query)
    Customer.where(event: event).operator.search(email_or_full_name_cont: query).result +
      Gtag.where(event: event).operator.includes(:customer).search(tag_uid_cont: query).result +
      Ticket.where(event: event).operator.includes(:customer).search(code_or_purchaser_email_or_purchaser_name_or_customer_full_name_cont: query).result
  end

  def self.find(event, id, klass)
    KLASSES[klass.to_sym].where(event: event).operator.find(id)
  end

  def self.all(event, operator, query)
    if operator.customer && !operator.customer.anonymous?
      (event.tickets.where(customer: nil).operator.search(code_or_purchaser_email_or_purchaser_name_or_customer_full_name_cont: query).result +
        event.gtags.where(customer: nil).operator.search(tag_uid_cont: query).result +
        event.customers.operator.anonymous.search(email_or_full_name_cont: query).result) - [operator]
    else
      (event.tickets.operator.search(code_or_purchaser_email_or_purchaser_name_or_customer_full_name_cont: query).result +
        event.gtags.operator.search(tag_uid_cont: query).result +
        event.customers.operator.search(email_or_full_name_cont: query).result) - [operator]
    end
  end
end
