class Admins::Events::CustomersController < Admins::Events::BaseController
  before_action :set_customer, except: [:index]

  def index
    @q = @current_event.customers.ransack(params[:q])
    @customers = @q.result.includes(:orders, :active_gtag, :tickets)
    authorize @customers
    @customers = @customers.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Customer.query_for_csv(@current_event))) }
    end
  end

  def show
    @transactions = @customer.transactions.debug
    @pokes = @customer.pokes.order(:source, :gtag_counter, :date)
  end

  def update
    respond_to do |format|
      if @customer.update(permitted_params)
        format.html { redirect_to [:admins, @current_event, @customer], notice: t("alerts.updated") }
        format.json { render status: :ok, json: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def reset_password
    password = "a123456"
    @customer.update!(password: password, password_confirmation: password)
    redirect_to admins_event_customer_path(@current_event, @customer), notice: "Password reset to '#{password}'"
  end

  def download_transactions
    @pdf_transactions = @customer.transactions.credit.status_ok.order(:gtag_counter)
    if @pdf_transactions.any?
      pdf = WickedPdf.new.pdf_from_string(render_to_string(action: :transactions_pdf, layout: false))
      send_data(pdf, filename: "transaction_history_#{@customer.id}.pdf", disposition: "attachment")
    else
      flash[:error] = t("alerts.customer_without_transactions")
      redirect_to admins_event_customer_path(@current_event, @customer)
    end
  end

  def resend_confirmation
    @customer.send_confirmation_instructions
    redirect_to [:admins, @current_event, @customer], notice: "Confirmation email sent"
  end

  private

  def permitted_params
    params.require(:customer).permit(:email, :first_name, :last_name, :phone, :postcode, :address, :city, :country, :gender, :banned)
  end

  def set_customer
    @customer = @current_event.customers.find(params[:id])
    authorize @customer
  end
end
