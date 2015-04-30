class Customers::OrdersController < Customers::BaseController

  def show
    @order = Order.find(params[:id])
  end

end