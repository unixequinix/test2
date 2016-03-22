class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    response.headers["Last-Modified"] = current_event.tickets.maximum(:updated_at)

    if request.headers["If-Modified-Since"]
      @tickets = current_event.tickets.where("updated_at > ?", request.headers["If-Modified-Since"])
      render(json: @tickets, each_serializer: Api::V1::TicketSerializer)
    else
      render(json: Rails.cache.fetch("v1/tickets", expires_in: 12.hours) { @fetcher.sql_tickets })
    end
  end

  def show
    @ticket = current_event.tickets.find_by_id(params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render(json: @ticket, serializer: Api::V1::TicketSerializer)
  end

  def reference
    @ticket = current_event.tickets.find_by_code(params[:id])

    render(status: :not_found, json: :not_found) && return if @ticket.nil?
    render(json: @ticket, serializer: Api::V1::TicketSerializer)
  end
end
