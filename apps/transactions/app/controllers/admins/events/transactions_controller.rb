class Admins::Events::TransactionsController < Admins::Events::BaseController
  before_action :set_type
  before_action :set_transactions, except: :show

  def search
    render :index
  end

  def show
    @transaction = "#{@type.capitalize}Transaction".constantize.find(params[:id])
    @gtag = Gtag.find_by_tag_uid(@transaction.customer_tag_uid)
    @profile = Profile.find_by_id(@transaction.profile_id)
    @operator = Gtag.find_by_tag_uid(@transaction.operator_tag_uid)
  end

  private

  def set_type
    @type = params[:type]
    redirect_to(admins_event_path(current_event)) && return unless @type
  end

  def set_transactions
    klass = "#{@type.capitalize}Transaction".constantize
    @q = klass.where(event: current_event).search(params[:q])
    @transactions = @q.result.page(params[:page]).includes(:profile, :station)
  end
end
