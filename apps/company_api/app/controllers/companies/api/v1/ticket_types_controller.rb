class Companies::Api::V1::TicketTypesController < Companies::Api::V1::BaseController
  def index
    @ticket_types = @fetcher.company_ticket_types

    render json: {
      event_id: current_event.id,
      ticket_types: @ticket_types.map do |ticket_type|
        Companies::Api::V1::TicketTypeSerializer.new(ticket_type)
      end
    }
  end

  def show
    @ticket_type = @fetcher.company_ticket_types.find_by(id: params[:id])

    if @ticket_type
      render json: Companies::Api::V1::TicketTypeSerializer.new(@ticket_type)
    else
      render status: :not_found,
             json: {
               error: I18n.t("company_api.ticket_type.not_found", ticket_type_id: params[:id])
             }
    end
  end

  def create
    @ticket_type = agreement.company_ticket_types.build(ticket_type_params)
    @ticket_type.event = current_event

    if @ticket_type.save
      render status: :created, json: Companies::Api::V1::TicketTypeSerializer.new(@ticket_type)
    else
      render status: :bad_request, json: { message: I18n.t("company_api.ticket_type.bad_request"),
                                           errors: @ticket_type.errors }
    end
  end

  def update
    @ticket_type = @fetcher.company_ticket_types.find_by(id: params[:id])

    if @ticket_type.update(ticket_type_params)
      render json: Companies::Api::V1::TicketTypeSerializer.new(@ticket_type)
    else
      render status: :bad_request,
             json: { message: I18n.t("company_api.ticket_type.bad_request"),
                     errors: @ticket_type.errors }
    end
  end

  private

  def ticket_type_params
    params.require(:ticket_type).permit(:name, :company_ticket_type_ref)
  end
end
