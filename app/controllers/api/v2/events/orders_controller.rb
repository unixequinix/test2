module Api::V2
  class Events::OrdersController < BaseController
    before_action :set_order, only: %i[show destroy complete]

    # PATCH/PUT api/v2/events/:event_id/orders/:id
    def complete
      if @order.completed?
        @order.errors.add(:status, "is already completed")
        render json: @order.errors, status: :unprocessable_entity
      else
        @order.complete!(order_params[:gateway], order_params[:payment_data], params[:send_email])
        render json: @order
      end
    end

    # GET api/v2/events/:event_id/orders
    def index
      @orders = @current_event.orders.includes(:order_items)
      authorize @orders

      paginate json: @orders, each_serializer: OrderSerializer
    end

    # GET api/v2/events/:event_id/orders/:id
    def show
      render json: @order, serializer: OrderSerializer
    end

    # DELETE api/v2/events/:event_id/orders/:id
    def destroy
      @order.destroy
      head(:ok)
    end

    private

    def set_order
      @order = @current_event.orders.find(params[:id])
      authorize @order
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(:status, :gateway, :payment_data)
    end
  end
end
