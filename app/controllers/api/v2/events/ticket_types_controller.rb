class Api::V2::Events::TicketTypesController < Api::V2::BaseController
  before_action :set_ticket_type, only: %i[tickets show update destroy]

  # GET /ticket_types
  def index
    @ticket_types = @current_event.ticket_types
    authorize @ticket_types

    render json: @ticket_types
  end

  # GET /ticket_types/:id/tickets
  def tickets
    @tickets = @ticket_type.tickets

    render json: @tickets, each_serializer: Api::V2::Simple::TicketSerializer
  end

  # GET /ticket_types/1
  def show
    render json: @ticket_type
  end

  # POST /ticket_types
  def create
    @ticket_type = @current_event.ticket_types.new(ticket_type_params)
    authorize @ticket_type

    if @ticket_type.save
      render json: @ticket_type, status: :created, location: [:admins, @current_event, @ticket_type]
    else
      render json: @ticket_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ticket_types/1
  def update
    if @ticket_type.update(ticket_type_params)
      render json: @ticket_type
    else
      render json: @ticket_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ticket_types/1
  def destroy
    @ticket_type.destroy
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
