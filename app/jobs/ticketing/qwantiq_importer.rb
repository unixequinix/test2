module Ticketing
  class QwantiqImporter < ApplicationJob
    def perform(ticket, integration)
      ticket = Hashie::Mash.new ticket
      ticket_type = integration.ticket_types.find_or_initialize_by(company_code: ticket.zoneId, event_id: integration.event_id)

      ticket_type.update!(name: ticket.zoneName, company: "Qwantiq")

      new_ticket = ticket_type.tickets.find_or_initialize_by(code: ticket.code, event_id: integration.event_id)
      new_ticket.update!(ticket_type: ticket_type, banned: !ticket.statusId.to_i.zero?)
    end
  end
end
