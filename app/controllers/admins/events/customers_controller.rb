class Admins::Events::CustomersController < Admins::Events::BaseController
  def index
    respond_to do |format|
      format.html do
        @q = current_event.customers.search(params[:q])
        @customers = @q.result.page(params[:page])
      end
      format.csv { send_data(CsvExporter.to_csv(Customer.query_for_csv(current_event))) }
    end
  end

  def search
    @q = current_event.customers.search(params[:q])
    @customers = @q.result.page(params[:page])
    render :index
  end

  def show
    @customer = current_event.customers.find(params[:id])
    @online_transactions = @customer.transactions
    @onsite_transactions = @customer.active_gtag.transactions
  end

  def reset_password
    @customer = current_event.customers.find(params[:id])
    @customer.update(password: "123456", password_confirmation: "123456")
    redirect_to admins_event_customer_path(current_event, @customer)
  end

  def fix_transaction
    credit_t = CreditTransaction.find(params[:transaction])
    money_t = MoneyTransaction.find_by(device_created_at: credit_t.device_created_at, customer_id: params[:id])
    fix_atts = { status_code: 0, status_message: "FIX" }
    credit_t.update!(fix_atts)
    money_t.update(fix_atts) if money_t

    redirect_to(admins_event_customer_path(current_event, params[:id]))
  end

  def download_transactions
    @pdf_transactions = @customer.transactions.credit.status_ok.not_record_credit.order("device_created_at asc")
    if @pdf_transactions.any?
      html = render_to_string(action: :transactions_pdf, layout: false)
      pdf = WickedPdf.new.pdf_from_string(html)
      send_data(pdf, filename: "transaction_history_#{@customer.id}.pdf", disposition: "attachment")
    else
      flash[:error] = I18n.t("alerts.customer_without_transactions")
      redirect_to(admins_event_customer_path(current_event, @customer))
    end
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(model_name: "Customer".constantize.model_name,
                                                   fetcher: current_event.customers,
                                                   search_query: params[:q],
                                                   page: params[:page],
                                                   context: view_context,
                                                   include_for_all_items: [:gtags, :tickets])
  end
end
