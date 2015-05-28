class Admins::CustomersController < Admins::BaseController

  def index
    @q = Customer.search(params[:q])
    @customers = @q.result(distinct: true).page(params[:page]).includes(:assigned_admission)
  end

  def search
    index
    render :index
  end

  def show
    @customer = Customer.find(params[:id])
  end

end
