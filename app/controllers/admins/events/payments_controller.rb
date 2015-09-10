class Admins::Events::PaymentsController < Admins::Events::BaseController

  def index
    @q = Payment.joins(order: :customer_event_profile)
      .where(customer_event_profiles: { event_id: current_event.id })
      .search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    respond_to do |format|
      format.html
      format.csv { send_data Payment.all.to_csv }
    end
  end

  def search
    @q = Payment.joins(order: :customer_event_profile)
      .where(customer_event_profiles: { event_id: current_event.id })
      .search(params[:q])
    @payments = @q.result(distinct: true).page(params[:page]).includes(:order)
    render :index
  end

  def show
    @payment = Payment.find(params[:id])
  end

end
