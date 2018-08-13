module Admins
  module Events
    class TransactionsController < Admins::Events::BaseController
      before_action :set_type, except: %i[index download_raw_transactions]
      before_action :set_transaction, only: %i[show update]

      TRANSACTIONS = { user_flag: UserFlagTransaction,
                       credit: CreditTransaction,
                       money: MoneyTransaction,
                       user_engagement: UserEngagementTransaction,
                       device: DeviceTransaction,
                       credential: CredentialTransaction,
                       access: AccessTransaction,
                       operator: OperatorTransaction,
                       order: OrderTransaction }.freeze

      def download_raw_transactions
        authorize Transaction.new
        respond_to do |format|
          format.csv { send_data(DownloadTransactionsQuery.new(@current_event).to_csv) }
        end
      end

      def index
        @transactions = params[:q] ? @current_event.transactions : @current_event.transactions.none
        authorize @transactions
        @q = @transactions.order(:device_created_at).search(params[:q])
        @transactions = @q.result.page(params[:page]).includes(:customer, :station)
      end

      def search
        @transactions = params[:q] ? @current_event.transactions : @current_event.transactions.none
        @q = @transactions.search(params[:q])
        @transactions = @q.result.page(params[:page]).includes(:customer, :station)
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
            format.json { render json: @transaction.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @transaction = @current_event.transactions.find(params[:id])
        authorize @transaction
        message = @transaction.destroy ? { notice: t('alerts.destroyed') } : { alert: @transaction.errors.full_messages.join(",") }
        return_url = request.referer || admins_event_transactions_path(@current_event)
        redirect_to return_url, message
      end

      private

      def set_transaction
        @transaction = @current_event.transactions.find_by(id: params[:id], type: "#{@type}_transaction".classify)
        authorize @transaction
      end

      def set_type
        @type = params[:type] || (params[:q][:type])
        @type&.camelcase
      end

      def permitted_params
        params.require(:credit_transaction).permit(:credits, :refundable_credits, :final_balance, :final_refundable_balance, :status_code)
      end
    end
  end
end
