module Api::V2
  class Events::TicketsController < BaseController
    before_action :set_ticket, only: %i[virtual_topup topup show update destroy ban unban]
    before_action :check_credits, only: %i[topup virtual_topup]

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

      @order = @ticket.customer.build_order([[@current_event.credit.id, params[:credits]]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/customers/:id/virtual_topup
    def virtual_topup
      @ticket.update!(customer: @current_event.customers.create!) if @ticket.customer.blank?

      @order = @ticket.customer.build_order([[@current_event.virtual_credit.id, params[:credits]]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
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

    # POST api/v2/events/:event_id/tickets
    def create_sonar_operator
      atts = sonar_ticket_params.dup

      stations = @current_event.stations.where(id: atts.delete(:stations))
      permissions = stations.map { |station| @current_event.operator_permissions.find_or_create_by!(station: station, group: OperatorPermission.groups[station.category], role: 1) }

      @ticket = @current_event.tickets.new(atts.merge(operator: true))
      authorize @ticket

      if @ticket.save
        if @ticket.customer
          customer = @ticket.customer
          customer.update!(operator: true)
          customer.build_order(permissions.map { |permission| [permission.id, 1] }).complete! if permissions.any?
        else
          render json: { errors: "Ticket must have a valid customer ID" }, status: :unprocessable_entity
        end

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

    def check_credits
      render(json: { credits: "Must be present and positive" }, status: :unprocessable_entity) unless params[:credits].to_f.positive?
    end

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
      params.require(:ticket).permit(:ticket_type_id, :code, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :customer_id, stations: [])
    end

    def sonar_ticket_params
      params.require(:ticket).permit(:ticket_type_id, :code, :customer_id, stations: [])
    end
  end
end
