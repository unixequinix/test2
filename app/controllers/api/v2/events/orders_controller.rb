class Api::V2::Events::OrdersController < Api::V2::BaseController
  before_action :set_order, only: %i[show update destroy complete]

  # PATCH/PUT /orders/1
  def complete
    if @order.completed?
      @order.errors.add(:status, "is already completed")
      render json: @order.errors, status: :unprocessable_entity
    else
      @order.complete!(order_params[:gateway], order_params[:payment_data])
      render json: @order
    end
  end

  # GET /orders
  def index
    @orders = @current_event.orders.includes(:order_items)
    authorize @orders

    render json: @orders, each_serializer: Api::V2::OrderSerializer
  end

  # GET /orders/1
  def show
    render json: @order, serializer: Api::V2::OrderSerializer
  end

  # POST /orders
  def create
    @order = @current_event.orders.new(order_params)
    authorize @order

    if @order.save
      render json: @order, status: :created, location: [:admins, @current_event, @order]
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
    head(:ok)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = @current_event.orders.find(params[:id])
    authorize @order
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:status, :completed_at, :gateway, :customer_id, :payment_data, :refund_data)
  end
end
