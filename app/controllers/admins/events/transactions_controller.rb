class Admins::Events::TransactionsController < Admins::Events::BaseController
  before_action :set_type
  before_action :set_transactions, except: :show
  before_action :set_transaction, only: [:show, :update, :fix]

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

  def fix
    find_atts = { device_created_at: @transaction.device_created_at, gtag_id: @transaction.gtag_id, type: "MoneyTransaction" }
    money_t = @current_event.transactions.find_by(find_atts)

    fix_atts = { status_code: 0, status_message: "FIX" }
    @transaction.update!(fix_atts)
    @transaction.gtag&.recalculate_balance
    money_t&.update(fix_atts)

    redirect_to(:back, notice: "Transaction fixed successfully")
  end

  private

  def set_transaction
    @transaction = @current_event.transactions.find_by(id: params[:id], type: "#{@type}_transaction".classify)
    authorize @transaction
  end

  def set_type
    @type = params[:type] || (params[:q] && params[:q][:type])
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
