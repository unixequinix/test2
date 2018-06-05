module Ticketing
  class Palco4Importer < ApplicationJob
    queue_as :default

    def perform(tickets, integration, ticket_type)
      values = tickets.map { |ticket| [integration.event_id, ticket_type.id, ticket["code"], !ticket["statusId"].to_i.zero?] }
      Ticket.import(%i[event_id ticket_type_id code banned], values, validate: true, on_duplicate_key_update: { conflict_target: %i[code event_id], columns: [:banned] })
    end
  end
end
