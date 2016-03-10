class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    json = Rails.cache.fetch("v1/tickets", expires_in: 12.hours) do
      @tickets = @fetcher.sql_tickets
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
