class Companies::Api::V1::TicketsController < Companies::Api::V1::BaseController
  def index
    @tickets = Ticket.search_by_company_and_event(current_company.name, current_event)

    render json: {
      event_id: current_event.id,
      tickets: @tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
    }
  end

  def show
    @ticket = Ticket.search_by_company_and_event(current_company.name, current_event)
              .find_by(id: params[:id])

    if @ticket
      render json: @ticket
    else
      render status: :not_found,
             json: { error: I18n.t("company_api.tickets.not_found", ticket_id: params[:id]) }
    end
  end

  def create
    @ticket = Ticket.new(ticket_params.merge(event: current_event))

    if @ticket.save
      render status: :created, json: Companies::Api::V1::TicketSerializer.new(@ticket)
    else
      render status: :bad_request,
             json: { message: I18n.t("company_api.tickets.bad_request"),
                     errors: @ticket.errors }
    end
  end

  def update
    @ticket = Ticket.search_by_company_and_event(current_company.name, current_event)
              .find_by(id: params[:id])

    update_params = ticket_params
    update_params[:purchaser_attributes].merge!(id: @ticket.purchaser.id)

    if @ticket.update(update_params)
      render json: Companies::Api::V1::TicketSerializer.new(@ticket)
    else
      render status: :bad_request, json: { message: I18n.t("company_api.tickets.bad_request"),
                                           errors: @ticket.errors }
    end
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
