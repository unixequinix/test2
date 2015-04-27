class Customer::OrdersController < Customer::BaseController
  before_action :check_has_ticket!

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(permitted_params)
    if @order.save
      flash[:notice] = "created TODO"
      redirect_to admin_entitlements_url
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def permitted_params
    params.require(:order).permit(:number)
  end
end