class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    render(json: [])
  end

  def show
    serializer = Api::V1::TicketWithCustomerSerializer
    @ticket = current_event.tickets.find_by_code(params[:id])
    render(json: @ticket, serializer: serializer) && return if @ticket
    render(json: :not_found, status: :not_found)
  end
end
