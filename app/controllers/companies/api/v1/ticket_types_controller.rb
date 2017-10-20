module Companies::Api
  class V1::TicketTypesController < Companies::Api::BaseController
    def index
      render json: {
        event_id: @current_event.id,
        ticket_types: ticket_types.map do |ticket_type|
          Companies::TicketTypeSerializer.new(ticket_type)
        end
      }
    end

    def show
      @ticket_type = ticket_types.find_by(id: params[:id])

      if @ticket_type
        render json: Companies::TicketTypeSerializer.new(@ticket_type)
      else
        render status: :not_found, json: { status: "not_found", error: "Ticket type with id #{params[:id]} not found." }
      end
    end

    def create
      @ticket_type = @company.ticket_types.build(ticket_type_params)
      @ticket_type.event = @current_event

      if @ticket_type.save
        render status: :created, json: Companies::TicketTypeSerializer.new(@ticket_type)
      else
        render status: :unprocessable_entity, json: { status: "unprocessable_entity", errors: @ticket_type.errors.full_messages }
      end
    end

    def update
      @ticket_type = ticket_types.find_by(id: params[:id])

      if @ticket_type
        if @ticket_type.update(ticket_type_params)
          render json: Companies::TicketTypeSerializer.new(@ticket_type)
        else
          render status: :unprocessable_entity, json: { status: "unprocessable_entity", errors: @ticket_type.errors.full_messages }
        end
      else
        render status: :not_found, json: { status: "not_found", error: "Ticket type with id #{params[:id]} not found." }
      end
    end

    private

    def ticket_type_params
      ticket_type_ref = params[:ticket_type][:ticket_type_ref]
      params[:ticket_type][:company_code] = ticket_type_ref if ticket_type_ref

      params.require(:ticket_type).permit(:name, :company_code)
    end
  end
end
