class Admins::PaymentsController < Admins::BaseController

  def index
    @q = Payment.search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
  end

  def search
    index
    render :index
  end

  def show
    @payment = Payment.find(params[:id])
  end

end
