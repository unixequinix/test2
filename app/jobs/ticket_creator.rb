class TicketCreator < ActiveJob::Base
  def perform(atts)
    ticket = Ticket.find_or_initialize_by(code: atts[:code], event_id: atts[:event_id])
    ticket.update(atts)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
