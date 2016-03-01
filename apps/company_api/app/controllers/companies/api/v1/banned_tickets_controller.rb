class Companies::Api::V1::BannedTicketsController < Companies::Api::V1::BaseController
  def index
    @banned_tickets = @fetcher.banned_tickets

    render json: {
      event_id: current_event.id,
      blacklisted_tickets: @banned_tickets.map do |ticket|
        Companies::Api::V1::TicketSerializer.new(ticket)
      end
    }
  end

  def create
    @ticket = @fetcher.tickets.find_by(code: params[:tickets_blacklist][:ticket_reference])

    render(status: :not_found,
           json: { message: I18n.t("company_api.tickets.not_found") }) && return unless @ticket

    @ticket.ban!
    render(status: :created,
           json: @ticket,
           serializer: Companies::Api::V1::TicketSerializer)
  end

  def destroy
    @banned_ticket = BannedTicket.includes(:ticket)
                     .find_by(tickets: { code: params[:id],
                                         event_id: current_event.id })

    render(status: :not_found, json: :not_found) && return if @banned_ticket.nil?
    render(status: :internal_server_error, json: :internal_server_error) &&
      return unless @banned_ticket.destroy
    render(status: :no_content, json: :no_content)
  end
end
