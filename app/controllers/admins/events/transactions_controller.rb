class Admins::Events::TransactionsController < Admins::Events::BaseController
  before_action :set_type
  before_action :set_transactions, except: :show
  before_action :set_transaction, only: [:show, :update]

  def search
    render :index
  end

  def show
    @gtag = Gtag.find_by_tag_uid(@transaction.customer_tag_uid)
    @profile = Profile.find_by_id(@transaction.profile_id)
    @operator = Gtag.find_by_tag_uid(@transaction.operator_tag_uid)
  end

  def update
    respond_to do |format|
      if @transaction.update(permitted_params)
        format.json { render status: :ok, json: @transaction }
      else
        format.json { render status: :unprocessable_entity, json: @transaction }
      end
    end
  end

  private

  def set_transaction
    @transaction = "#{@type}_transaction".constantize.find(params[:id])
  end

  def set_type
    @type = params[:type]
    redirect_to(admins_event_path(current_event)) && return unless @type
  end

  def set_transactions
    klass = "#{@type}_transaction".classify.constantize
    @q = klass.where(event: current_event).search(params[:q])
    @transactions = @q.result.page(params[:page]).includes(:profile, :station)
  end

  def permitted_params
    params.require(:credit_transaction)
          .permit(:credits, :refundable_credits, :final_balance, :final_refundable_balance, :status_code)
  end
end
