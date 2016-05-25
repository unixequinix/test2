class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    render(json: @fetcher.sql_tickets)
  end

  def show
    @ticket = current_event.tickets.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render(json: @ticket, serializer: Api::V1::TicketWithCustomerSerializer)
  end

  def reference
    serializer = Api::V1::TicketWithCustomerSerializer
    @ticket = current_event.tickets.find_by_code(params[:id])
    render(json: @ticket, serializer: serializer) && return if @ticket
    render(json: :not_found, status: :not_found)

    # if TicketDecoder::SonarDecoder.valid_code?(params[:id])
    #   render(json: Ticket.new(code: params[:id]), serializer: serializer)
    # else
    #   render(json: :not_found, status: :not_found)
    # end
  end
end
