module Ticketing
  class Palco4Importer < ApplicationJob
    queue_as :critical

    def perform(values)
      Ticket.import(%i[event_id ticket_type_id code banned], values, validate: true, on_duplicate_key_update: { conflict_target: %i[code event_id], columns: [:banned] })
    end
  end
end
