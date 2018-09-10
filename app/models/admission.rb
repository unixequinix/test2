class Admission
  attr_accessor :event

  KLASSES = { ticket: Ticket, gtag: Gtag, customer: Customer }.freeze

  def self.search(event, query)
    Customer.where(event: event, operator: false).search(email_or_first_name_or_last_name_cont: query).result +
      Gtag.where(event: event, operator: false).includes(:customer).search(tag_uid_cont: query).result +
      Ticket.where(event: event, operator: false).includes(:customer).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result
  end

  def self.find(event, id, klass)
    KLASSES[klass.to_sym].where(event: event).find(id)
  end

  def self.all(event, admission, query)
    if admission.customer && !admission.customer.anonymous?
      (event.tickets.where(customer: nil, operator: false).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result +
        event.gtags.where(customer: nil, operator: false).search(tag_uid_cont: query).result +
        event.customers.where(operator: false).anonymous.search(email_or_first_name_or_last_name_cont: query).result) - [admission]
    else
      (event.tickets.where(operator: false).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result +
        event.gtags.where(operator: false).search(tag_uid_cont: query).result +
        event.customers.where(operator: false).search(email_or_first_name_or_last_name_cont: query).result) - [admission]
    end
  end
end
