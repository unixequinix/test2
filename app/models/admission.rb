class Admission
  KLASSES = { ticket: Ticket, gtag: Gtag, customer: Customer }.freeze

  def self.search(event, query)
    Ticket.where(event: event).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: query).result +
      Gtag.where(event: event).search(tag_uid_cont: query).result +
      Customer.where(event: event).search(email_or_first_name_or_last_name_cont: query).result
  end

  def self.find(event, id, klass)
    KLASSES[klass.to_sym].where(event: event).find(id)
  end

  def self.all(event, admission, q)
    if admission.customer && !admission.customer.anonymous?
      (event.tickets.where(customer: nil).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: q).result +
        event.gtags.where(customer: nil).search(tag_uid_cont: q).result +
        event.customers.anonymous.search(email_or_first_name_or_last_name_cont: q).result) - [admission]
    else
      (event.tickets.search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: q).result +
        event.gtags.search(tag_uid_cont: q).result +
        event.customers.search(email_or_first_name_or_last_name_cont: q).result) - [admission]
    end
  end
end
