class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    tickets = @fetcher.tickets.page(params[:page]).per(10000)
    json = cache ["v1", "tickets", "#{params[:page] || 0}"] do
     render_to_string json: tickets, each_serializer: Api::V1::TicketSerializer
    end
    render json: json
  end

  def show
    @ticket = @fetcher.tickets.find_by(id: params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render json: @ticket, serializer: Api::V1::TicketSerializer
  end

  def reference
    @ticket = @fetcher.tickets.find_by(code: params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render json: @ticket, serializer: Api::V1::TicketSerializer
  end
end
