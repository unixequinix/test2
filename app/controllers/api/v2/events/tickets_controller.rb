module Api::V2
  class Events::TicketsController < BaseController
    before_action :set_ticket, only: %i[topup show update destroy ban unban]

    # POST api/v2/events/:event_id/tickets/:id/ban
    def ban
      if @ticket.update(banned: true)
        render json: @ticket
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/tickets/:id/unban
    def unban
      if @ticket.update(banned: false)
        render json: @ticket
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/customers/:id/topup
    def topup
      @ticket.update!(customer: @current_event.customers.create!) if @ticket.customer.blank?

      @order = @ticket.customer.build_order([[@current_event.credit.id, params[:credits]]])

      if @order.save
        @order.complete!(params[:gateway])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # GET api/v2/events/:event_id/tickets
    def index
      @tickets = @current_event.tickets
      authorize @tickets

      render json: @tickets, each_serializer: Simple::TicketSerializer
    end

    # GET api/v2/events/:event_id/tickets/:id
    def show
      render json: @ticket, serializer: TicketSerializer
    end

    # POST api/v2/events/:event_id/tickets
    def create
      @ticket = @current_event.tickets.new(ticket_params)
      authorize @ticket

      if @ticket.save
        render json: @ticket, status: :created, location: [:admins, @current_event, @ticket]
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/tickets/:id
    def update
      if @ticket.update(ticket_params)
        render json: @ticket
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/tickets/:id
    def destroy
      @ticket.destroy
      head(:ok)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      tickets = @current_event.tickets
      
      Rollbar.silenced do
        ticket_id = tickets.find_by(id: params[:id])&.id || tickets.find_by(code: params[:id])&.id
        
        @ticket = tickets.find(ticket_id)
        authorize @ticket
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ticket_params
      params.require(:ticket).permit(:ticket_type_id, :code, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :customer_id) # rubocop:disable Metrics/LineLength
    end
  end
end
