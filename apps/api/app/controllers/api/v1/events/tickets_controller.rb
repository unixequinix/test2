class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    @tickets = Ticket.includes(:company_ticket_type, :credential_assignments)
               .where(event_id: current_event.id)
    render json: @tickets, each_serializer: Api::V1::TicketSerializer
  end

  def show
    @ticket = Ticket.includes(:company_ticket_type, :credential_assignments)
              .find_by(event_id: current_event.id, id: params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render json: @ticket, serializer: Api::V1::TicketSerializer
  end

  def reference
    @ticket = Ticket.includes(:company_ticket_type, :credential_assignments)
              .find_by(event_id: current_event.id, code: params[:id])
    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render json: @ticket, serializer: Api::V1::TicketSerializer
  end
end
