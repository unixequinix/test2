module Api::V2
  class Events::TicketTypesController < BaseController
    before_action :set_ticket_type, only: %i[tickets show update destroy bulk_upload]

    def bulk_upload
      errors = params[:tickets].to_a.reject { |code| @current_event.tickets.create(code: code, ticket_type: @ticket_type).valid? }

      if errors.empty?
        render json: @ticket_type, status: :created, location: [:admins, @current_event, @ticket_type]
      else
        render json: { errors: "#{errors.count} codes could not be created. #{errors.to_sentence}" }, status: :unprocessable_entity
      end
    end

    # GET api/v2/events/:event_id/ticket_types
    def index
      @ticket_types = @current_event.ticket_types
      authorize @ticket_types

      paginate json: @ticket_types
    end

    # GET api/v2/events/:event_id/ticket_types/:id/tickets
    def tickets
      @tickets = @ticket_type.tickets

      render json: @tickets, each_serializer: Simple::TicketSerializer
    end

    # GET api/v2/events/:event_id/ticket_types/:id
    def show
      render json: @ticket_type, serializer: Full::TicketTypeSerializer
    end

    # POST api/v2/events/:event_id/ticket_types
    def create
      @ticket_type = @current_event.ticket_types.new(ticket_type_params)
      authorize @ticket_type

      if @ticket_type.save
        render json: @ticket_type, status: :created, location: [:admins, @current_event, @ticket_type]
      else
        render json: @ticket_type.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/ticket_types/:id
    def update
      if @ticket_type.update(ticket_type_params)
        render json: @ticket_type
      else
        render json: @ticket_type.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/ticket_types/:id
    def destroy
      @ticket_type.destroy
      head(:ok)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_type
      @ticket_type = @current_event.ticket_types.find(params[:id])
      authorize @ticket_type
    end

    # Only allow a trusted parameter "white list" through.
    def ticket_type_params
      params.require(:ticket_type).permit(:name, :company_id, :company_code)
    end
  end
end
