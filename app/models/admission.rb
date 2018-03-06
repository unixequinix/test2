class Admission
  KLASSES = { ticket: Ticket, gtag: Gtag, customer: Customer }.freeze

  def self.search(event, q)
    Ticket.where(event: event).search(code_or_purchaser_email_or_purchaser_first_name_or_purchaser_last_name_cont: q).result +
      Gtag.where(event: event).search(tag_uid_cont: q).result +
      Customer.where(event: event).search(email_or_first_name_or_last_name_cont: q).result
  end

  def self.find(event, id, klass)
    KLASSES[klass.to_sym].where(event: event).find(id)
  end
end
