class Admins::Events::OrdersController < Admins::Events::BaseController
  before_action :set_order, only: %i[show destroy]

  def index
    @orders = @current_event.orders.order(id: :desc)
    authorize @orders
    @orders = @orders.page(params[:page])
    @counts = @current_event.orders.group(:status).count

    @graph = %w[in_progress completed cancelled failed].map do |action|
      data = OrderItem.where(order: @current_event.orders.where(status: action)).group_by_day(:created_at).sum(:amount)
      data = data.collect { |k, v| [k, v.to_i.abs] }
      { name: action, data: Hash[data] }
    end
  end

  def new
    @customer = @current_event.customers.find(params[:customer_id])
    @order = @current_event.orders.new(customer: @customer)
    authorize @order
  end

  def create
    @customer = @current_event.customers.find(permitted_params[:customer_id])
    @order = @customer.build_order([[@current_event.credit.id, permitted_params[:credits]]])
    authorize @order

    if @order.save
      @order.update(gateway: "admin", status: "completed", completed_at: Time.zone.now)
      OrderTransaction.write!(@current_event, "order_created", :admin, @customer, current_user, order_id: @order.id)
      redirect_to [:admins, @current_event, @customer], notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def destroy
    message = @order.destroy ? { notice: t('alerts.destroyed') } : { alert: @order.errors.full_messages.join(",") }
    redirect_to request.referer, message
  end

  private

  def set_order
    @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
    authorize @order
  end

  def permitted_params
    params.require(:order).permit(:status, :customer_id, :credits)
  end
end
