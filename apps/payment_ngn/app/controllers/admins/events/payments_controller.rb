class Admins::Events::PaymentsController < Admins::Events::PaymentsBaseController

  def index
    @q = @fetcher.payments.search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    @payments_count = @q.result(distinct: true).count
    respond_to do |format|
      format.html
      format.csv { send_data Csv::CsvExporter.to_csv(Payment.all) }
    end
  end

  def search
    @q = @fetcher.payments.search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    render :index
  end

  def show
    @payment = @fetcher.payments.find(params[:id])
  end

end
