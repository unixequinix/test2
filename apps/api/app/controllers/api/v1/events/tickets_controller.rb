class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    @tickets = Paginator::ApiPaginator.paginate(@fetcher.tickets, params[:page])

    render json: @tickets, each_serializer: Api::V1::TicketSerializer
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
