class Palco4Importer < ApplicationJob
  def perform(ticket, event)
    ticket = Hashie::Mash.new ticket

    ticket_type = event.ticket_types.find_or_initialize_by(company_code: ticket.zoneId, company: "Palco4")
    ticket_type.update!(name: ticket.zoneName)
    new_ticket = event.tickets.find_or_initialize_by(code: ticket.code)
    new_ticket.update!(ticket_type: ticket_type, purchaser_first_name: ticket.buyerName, purchaser_last_name: ticket.buyerSurName, purchaser_email: ticket.buyerEmail)
  end
end
