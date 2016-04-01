class Companies::Api::V1::TicketsController < Companies::Api::V1::BaseController
  def index
    @tickets = @fetcher.tickets
               .joins("FULL OUTER JOIN purchasers
                       ON purchasers.credentiable_id = tickets.id
                       AND purchasers.credentiable_type = 'Ticket'
                       AND purchasers.deleted_at IS NULL")
               .includes(:purchaser)

    render json: {
      event_id: current_event.id,
      tickets: @tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
    }
  end

  def show
    @ticket = @fetcher.tickets.find_by(id: params[:id])

    if @ticket
      render json: @ticket, serializer: Companies::Api::V1::TicketSerializer
    else
      render(status: :not_found,
             json: { status: "not_found", error: "Ticket with id #{params[:id]} not found." })
    end
  end

  def create
    @ticket = Ticket.new(ticket_params.merge(event: current_event))

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity", error: "Ticket type not found." }) &&
      return unless validate_ticket_type!

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity",
                   error: @ticket.errors.full_messages }) && return unless @ticket.save

    render(status: :created, json: Companies::Api::V1::TicketSerializer.new(@ticket))
  end

  def update # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    @ticket = @fetcher.tickets.find_by(id: params[:id])

    render(status: :not_found,
           json: { status: "not_found", error: "Ticket with id #{params[:id]} not found." }) &&
      return unless @ticket

    update_params = ticket_params
    purchaser_attributes = update_params[:purchaser_attributes]
    purchaser_attributes.merge!(id: @ticket.purchaser.id) if purchaser_attributes

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity",
                   error: "The ticket type doesn't belongs to your company" }) &&
      return unless validate_ticket_type!

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity", errors: @ticket.errors.full_messages }) &&
      return unless @ticket.update(update_params)

    render(json: Companies::Api::V1::TicketSerializer.new(@ticket))
  end

  private

  def ticket_params
    params[:ticket][:code] = params[:ticket][:ticket_reference]
    params[:ticket][:company_ticket_type_id] = params[:ticket][:ticket_type_id] if
      params[:ticket][:ticket_type_id]

    params.require(:ticket).permit(:code,
                                   :company_ticket_type_id,
                                   purchaser_attributes: [:id, :first_name, :last_name, :email])
  end
end
