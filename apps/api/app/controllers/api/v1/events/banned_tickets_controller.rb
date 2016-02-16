class Api::V1::Events::BannedTicketsController < Api::V1::Events::BaseController
  def index
    @banned_tickets = Ticket.banned.where(event_id: current_event.id)
    render json: @banned_tickets, each_serializer: Api::V1::BannedTicketSerializer
  end
end
