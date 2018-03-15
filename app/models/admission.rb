class Admission
  attr_accessor :event

  KLASSES = { ticket: Ticket, gtag: Gtag, customer: Customer }.freeze

  def self.search(event, query)
    Customer.where(event: event).search(email_or_first_name_or_last_name_cont: query).result +
      Gtag.where(event: event).includes(:customer).search(tag_uid_cont: query).result +
      Ticket.where(event: event).includes(:customer).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result
  end

  def self.find(event, id, klass)
    KLASSES[klass.to_sym].where(event: event).find(id)
  end

  def self.all(event, admission, query)
    if admission.customer && !admission.customer.anonymous?
      (event.tickets.where(customer: nil).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result +
        event.gtags.where(customer: nil).search(tag_uid_cont: query).result +
        event.customers.anonymous.search(email_or_first_name_or_last_name_cont: query).result) - [admission]
    else
      (event.tickets.search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result +
        event.gtags.search(tag_uid_cont: query).result +
        event.customers.search(email_or_first_name_or_last_name_cont: query).result) - [admission]
    end
  end
end
