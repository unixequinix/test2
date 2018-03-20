class Palco4Importer < ApplicationJob
  def perform(ticket, event)
    ticket = Hashie::Mash.new ticket

    company_code = ticket.zoneId
    ticket_name = ticket.zoneName
    ticket_code = ticket.code
    first_name = ticket.buyerName
    last_name = ticket.buyerSurName
    email = ticket.buyerEmail

    ticket_type = event.ticket_types.find_or_initialize_by(company_code: company_code, company: "Sónar+D 2018")
    ticket_type.update!(name: ticket_name)
    new_ticket = event.tickets.find_or_initialize_by(code: ticket_code)
    new_ticket.update!(ticket_type: ticket_type, purchaser_first_name: first_name, purchaser_last_name: last_name, purchaser_email: email)
  end
end
