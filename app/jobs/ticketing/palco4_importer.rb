module Ticketing
  class Palco4Importer < ApplicationJob
    def perform(ticket, integration)
      ticket = Hashie::Mash.new ticket
      ticket_type = integration.ticket_types.find_or_initialize_by(company_code: ticket.zoneId, event_id: integration.event_id)

      ticket_type.update!(name: ticket.zoneName, company: "Palco4")

      new_ticket = ticket_type.tickets.find_or_initialize_by(code: ticket.code, event_id: integration.event_id)
      new_ticket.update!(ticket_type: ticket_type, purchaser_first_name: ticket.buyerName, purchaser_last_name: ticket.buyerSurName, purchaser_email: ticket.buyerEmail, banned: !ticket.statusId.to_i.zero?)
    end
  end
end
