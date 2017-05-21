class Admins::Events::TransactionsController < Admins::Events::BaseController
  before_action :set_type, except: :index
  before_action :set_transactions, except: %i[index show fix status_9 status_0]
  before_action :set_transaction, only: %i[show update fix status_9 status_0]

  def index
    @transactions = params[:q] ? @current_event.transactions : @current_event.transactions.none
    authorize @transactions
    @q = @transactions.search(params[:q])
    @transactions = @q.result.page(params[:page]).includes(:customer, :station)
  end

  def search
    authorize @transactions
    render :index
  end

  def show
    @gtag = @current_event.gtags.find_by(tag_uid: @transaction.customer_tag_uid)
    @customer = @current_event.customers.find_by(id: @transaction.customer_id)
    @operator = @current_event.gtags.find_by(tag_uid: @transaction.operator_tag_uid)
  end

  def update
    respond_to do |format|
      if @transaction.update(permitted_params)
        format.json { render status: :ok, json: @transaction }
      else
        format.json { render json: { errors: @transaction.errors }, status: :unprocessable_entity }
      end
    end
  end

  def status_9
    @transaction.update(status_code: 9, status_message: "cancelled by user #{current_user.email}")
    @transaction.gtag&.recalculate_balance
    redirect_to(:back, notice: "Transaction cancelled successfully")
  end

  def status_0
    @transaction.update(status_code: 0, status_message: "accepted by user #{current_user.email}")
    @transaction.gtag&.recalculate_balance
    redirect_to(:back, notice: "Transaction accepted successfully")
  end

  private

  def set_transaction
    @transaction = @current_event.transactions.find_by(id: params[:id], type: "#{@type}_transaction".classify)
    authorize @transaction
  end

  def set_type
    @type = params[:type] || (params[:q] && params[:q][:type])
    @type&.camelcase
  end

  def set_transactions
    @transactions = "#{@type}_transaction".classify.constantize.where(event: @current_event)
    authorize @transactions
    @q = @transactions.search(params[:q])
    @transactions = @q.result.page(params[:page]).includes(:customer, :station)
  end

  def permitted_params
    params.require(:credit_transaction).permit(:credits, :refundable_credits, :final_balance, :final_refundable_balance, :status_code)
  end
end
