class Companies::Api::V1::TicketsController < Companies::Api::V1::BaseController
  def index
    render json: {
      event_id: @current_event.id,
      tickets: tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
    }
  end

  def show
    @ticket = tickets.find_by(id: params[:id])

    if @ticket
      render json: @ticket, serializer: Companies::Api::V1::TicketSerializer
    else
      render(status: :not_found, json: { status: "not_found", error: "Ticket with id #{params[:id]} not found." })
    end
  end

  def create
    @ticket = Ticket.new(ticket_params.merge(event: @current_event))

    unless validate_ticket_type!
      render(status: :unprocessable_entity, json: { status: "unprocessable_entity", error: "Ticket type not found." }) && return
    end

    unless @ticket.save
      render(status: :unprocessable_entity, json: { status: "unprocessable_entity", error: @ticket.errors.full_messages }) && return
    end

    render(status: :created, json: Companies::Api::V1::TicketSerializer.new(@ticket))
  end

  def bulk_upload
    render(status: :bad_request, json: { error: "tickets key is missing" }) && return unless params[:tickets]
    errors = { atts: [] }

    params[:tickets].each do |atts|
      atts = ActionController::Parameters.new(atts.to_unsafe_h)

      atts.merge!(
        code: atts.delete(:ticket_reference),
        ticket_type_id: atts.delete(:ticket_type_id),
        event_id: @current_event.id,
        purchaser_first_name: atts[:purchaser_attributes].delete(:first_name),
        purchaser_last_name: atts[:purchaser_attributes].delete(:last_name),
        purchaser_email: atts[:purchaser_attributes].delete(:email)
      )
      ticket_atts = atts.permit(:code, :ticket_type_id, :event_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email)

      ticket = @current_event.tickets.find_by(code: ticket_atts[:code])
      ticket ||= @current_event.tickets.create(ticket_atts)

      errors[:atts] << { ticket: ticket.code, errors: ticket.errors.full_messages } && next unless ticket.valid?
    end

    errors.delete_if { |_, v| v.compact.empty? }

    render(status: :unprocessable_entity, json: { status: :unprocessable_entity, errors: errors }) && return if errors.any?
    render(status: :created, json: :created)
  end

  def update
    @ticket = tickets.find_by(id: params[:id])

    render(status: :not_found, json: { status: "not_found", error: "Ticket with id #{params[:id]} not found." }) && return unless @ticket
    render(status: :unprocessable_entity, json: { status: "unprocessable_entity", error: "The ticket type doesn't belongs to your company" }) && return unless validate_ticket_type! # rubocop:disable Metrics/LineLength
    render(status: :unprocessable_entity, json: { status: "unprocessable_entity", errors: @ticket.errors.full_messages }) && return unless @ticket.update(ticket_params) # rubocop:disable Metrics/LineLength
    render(json: Companies::Api::V1::TicketSerializer.new(@ticket))
  end

  private

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:ticket_type_id]
    return true unless ticket_type_id
    @current_event.ticket_types.find_by(id: ticket_type_id, company: @company)
  end

  def ticket_params
    ticket = params[:ticket]
    purchaser = ticket[:purchaser_attributes] || {}
    ticket[:code] = ticket[:ticket_reference]
    ticket[:ticket_type_id] = ticket[:ticket_type_id] if ticket[:ticket_type_id]
    ticket.merge!(purchaser_first_name: purchaser[:first_name], purchaser_last_name: purchaser[:last_name], purchaser_email: purchaser[:email])

    params.require(:ticket).permit(:code, :ticket_type_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email)
  end
end
