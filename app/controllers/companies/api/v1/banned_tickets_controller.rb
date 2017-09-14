class Companies::Api::V1::BannedTicketsController < Companies::Api::V1::BaseController
  def index
    render json: {
      event_id: @current_event.id,
      blacklisted_tickets: banned_tickets.map do |ticket|
        Companies::Api::V1::TicketSerializer.new(ticket)
      end
    }
  end

  def create # rubocop:disable Metrics/PerceivedComplexity
    t_code = params[:tickets_blacklist] && params[:tickets_blacklist][:ticket_reference]
    render(status: :bad_request, json: { error: "Ticket reference is missing." }) && return unless t_code

    @ticket = tickets.find_by(code: t_code)

    unless @ticket
      dec = SonarDecoder.perform(t_code)
      render(status: :not_found, json: { status: :not_found, error: "Invalid ticket reference." }) && return unless dec

      ctt = ticket_types.find_by(company_code: dec)
      render(status: :not_found, json: { status: :not_found, error: "Ticket Type not found." }) && return unless ctt

      @ticket = tickets.create!(ticket_type: ctt, code: t_code)
    end

    @ticket.update!(banned: true)

    render(status: :created, json: @ticket, serializer: Companies::Api::V1::TicketSerializer)
  end

  def destroy
    ticket = tickets.find_by(code: params[:id])
    unless ticket
      render(status: :not_found,
             json: { status: :not_found, message: :not_found }) && return
    end

    ticket.update!(banned: false)
    render(status: :no_content, json: :no_content)
  end
end
