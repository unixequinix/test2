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
    @ticket = Ticket.new(ticket_params)
    @ticket.event = current_event
    @ticket.build_purchaser(email: params[:ticket][:purchaser_email],
                            first_name: params[:ticket][:purchaser_first_name],
                            last_name: params[:ticket][:purchaser_last_name])

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

    if @ticket.update(ticket_params) && update_purchaser(@ticket)
      render json: Companies::Api::V1::TicketSerializer.new(@ticket)
    else
      render status: :bad_request, json: { message: I18n.t("company_api.tickets.bad_request"),
                                           errors: @ticket.errors }
    end
  end

  private

  def ticket_params
    params[:ticket][:code] = params[:ticket][:ticket_reference]
    params[:ticket][:company_ticket_type_id] = params[:ticket][:ticket_type_id]

    params.require(:ticket).permit(:code, :company_ticket_type_id)
  end

  def update_purchaser(ticket)
    ticket.purchaser.update(email: params[:ticket][:purchaser_email],
                            first_name: params[:ticket][:purchaser_first_name],
                            last_name: params[:ticket][:purchaser_last_name])
  end
end
