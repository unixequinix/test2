class Customers::CheckoutsController < Customers::BaseController
  before_action :check_has_ticket!

  def new
    @checkout_form = CheckoutForm.new(current_customer)
    @credits = Credit.all.includes(:online_product)
  end

  def create
    @checkout_form = CheckoutForm.new(current_customer)
    if @checkout_form.submit(params[:checkout_form])
      flash[:notice] = "created TODO"
      redirect_to customers_order_url(@checkout_form.order)
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end
end
