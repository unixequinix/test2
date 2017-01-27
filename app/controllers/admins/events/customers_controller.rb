class Admins::Events::CustomersController < Admins::Events::BaseController
  before_action :set_customer, except: [:index]

  def index
    @customers = @current_event.customers
    authorize @customers
    @customers = @customers.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Customer.query_for_csv(@current_event))) }
    end
  end

  def show
    @online_transactions = @customer.transactions.online.order(:counter)
    @onsite_transactions = @customer.active_gtag&.transactions&.onsite&.order(:gtag_counter)
  end

  def reset_password
    password = "123456"
    @customer.update(password: password, password_confirmation: password)
    redirect_to admins_event_customer_path(@current_event, @customer), notice: "Password reset to '#{password}'"
  end

  def download_transactions
    @pdf_transactions = @customer.transactions.credit.status_ok.order(:gtag_counter)
    if @pdf_transactions.any?
      html = render_to_string(action: :transactions_pdf, layout: false)
      pdf = WickedPdf.new.pdf_from_string(html)
      send_data(pdf, filename: "transaction_history_#{@customer.id}.pdf", disposition: "attachment")
    else
      flash[:error] = I18n.t("alerts.customer_without_transactions")
      redirect_to(admins_event_customer_path(@current_event, @customer))
    end
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
    authorize @customer
  end
end
