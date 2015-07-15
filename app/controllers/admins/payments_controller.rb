class Admins::PaymentsController < Admins::BaseController

  def index
    @q = Payment.search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    respond_to do |format|
      format.html
      format.csv { send_data Payment.all.to_csv }
    end
  end

  def search
    @q = Payment.search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    render :index
  end

  def show
    @payment = Payment.find(params[:id])
  end

end
