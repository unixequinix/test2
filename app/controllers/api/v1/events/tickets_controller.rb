class Api::V1::Events::TicketsController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]
    tickets = sql_tickets(modified) || []

    if tickets.present?
      date = JSON.parse(tickets).map { |pr| pr["updated_at"] }.sort.last
      response.headers["Last-Modified"] = date.to_datetime.httpdate
    end

    status = tickets.present? ? 200 : 304 if modified
    status ||= 200

    render(status: status, json: tickets)
  end

  def show
    ticket = current_event.tickets.find_by_code(params[:id])

    render(json: :not_found, status: :not_found) && return unless ticket
    render(json: ticket, serializer: Api::V1::TicketSerializer)
  end
end
