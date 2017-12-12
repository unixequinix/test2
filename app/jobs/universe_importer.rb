class UniverseImporter < ApplicationJob
  def perform(ticket, event)
    ticket = Hashie::Mash.new ticket

    if ticket.event_id.present?
      name = "Universe - #{ticket.event_id}"
      company_code = ticket.rate_id
      ticket_name = ticket.name
      ticket_code = ticket.qr_code
      first_name = ticket.guest_first_name
      last_name = ticket.guest_last_name
      email = ticket.guest_email
    else
      name = "Universe - #{ticket.event.id}"
      company_code = ticket.ticket_type.id
      ticket_name = ticket.ticket_type.name
      ticket_code = ticket.token
      first_name = ticket.answers.first.value
      last_name = ticket.answers.second.value
      email = ticket.answers.third.value
    end

    company = event.companies.find_or_create_by(name: name)
    ticket_type = event.ticket_types.find_or_initialize_by(company_code: company_code, company: company)
    ticket_type.update!(name: ticket_name)
    new_ticket = event.tickets.find_or_initialize_by(code: ticket_code)
    new_ticket.update!(ticket_type: ticket_type, purchaser_first_name: first_name, purchaser_last_name: last_name, purchaser_email: email)
  end
end
