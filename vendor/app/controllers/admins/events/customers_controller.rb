module Admins
  module Events
    class CustomersController < Admins::Events::BaseController
      before_action :set_customer, except: %i[index sample_csv import]
      before_action :set_operator, only: %i[index import]

      def index
        @q = @current_event.customers.where(operator: @operator_mode).ransack(params[:q])
        @customers = @q.result.includes(:active_gtag, :tickets)
        authorize @customers
        @customers = @customers.page(params[:page])
        @bad_customers = params[:bad_customers] # Used only for import
        respond_to do |format|
          format.html
          format.csv { send_data(CsvExporter.to_csv(@current_event.customers.registered.select(:first_name, :last_name, :email, :phone, :postcode, :address, :city, :country, :gender))) }
        end
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

      def confirm_customer
        @customer.confirm
        redirect_to [:admins, @current_event, @customer], notice: "Customer confirmed"
      end

      def merge
        admission = Admission.find(@current_event, params[:adm_id], params[:adm_class])
        admission.update(customer: @current_event.customers.create!) if admission.customer.blank?

        result = @customer.anonymous? ? Customer.claim(@current_event, admission.customer, @customer) : Customer.claim(@current_event, @customer, admission.customer)

        @customer.reload.validate_gtags unless @customer.anonymous?
        admission.reload.customer.validate_gtags unless admission.customer.anonymous?

        alert = result.present? ? { notice: "Admissions were sucessfully merged" } : { alert: "Admissions could not be merged" }
        redirect_to [:admins, @current_event, (result || admission)], alert
      end

      def edit_pokes
        @pokes = @customer.active_gtag.pokes.where.not(credit_id: nil).for_listings
      end

      def import
        authorize @current_event.customers.new
        path = [:admins, @current_event, :customers, operator: @operator_mode]
        redirect_to(path, alert: t("alerts.import.empty_file")) && return unless params[:file]
        file = params[:file][:data].tempfile.path
        redirect_to(path, alert: 'CSV is too big, please use maximum 10.000 lines per import') && return if File.open(file).readlines.size > 10_001
        count = 0
        line = 0
        send_email = params[:send_email].present?
        bad_customers = {}

        CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, i|
          line = i + 1
          ticket_type = @current_event.ticket_types.find_or_initialize_by(name: row.field("ticket_type"), operator: @operator_mode)
          ticket = @current_event.tickets.find_or_initialize_by(code: row.field("reference"), ticket_type: ticket_type, operator: @operator_mode)
          if ticket.present? && ticket.customer.blank?
            customer = @current_event.customers.find_or_initialize_by(operator: @operator_mode, agreed_on_registration: true, anonymous: false, first_name: row.field("first_name"), last_name: row.field("last_name"), email: row.field("email"))
            customer.tickets << ticket
            customer.skip_confirmation! unless send_email
            customer.save(validate: false) # No password
            count += 1
          else
            key = ticket.present? ? :customer_exists : :ticket_error
            bad_customers[key] = [] unless bad_customers[key]
            bad_customers[key].push row
          end
        rescue StandardError => e
          bad_customers[:error_parsing] = "Error parsing row: #{line}. #{e.message}"
        end

        if count.positive?
          redirect_to(admins_event_customers_path(@current_event, bad_customers: bad_customers, operator: @operator_mode), notice: t('alerts.import.success', count: count, item: @operator_mode ? 'Operators' : 'Customers').to_s)
        else
          redirect_to(admins_event_customers_path(@current_event, bad_customers: bad_customers, operator: @operator_mode), alert: 'Nothing imported')
        end
      end

      def sample_csv
        authorize @current_event.tickets.new
        header = %w[ticket_type reference first_name last_name email]
        data = [["VIP Night", "0011223344", "Jon", "Snow", "jon@snow.com"], ["VIP Day", "4433221100", "Arya", "Stark", "arya@stark.com"]]

        respond_to do |format|
          format.csv { send_data(CsvExporter.sample(header, data)) }
        end
      end

      private

      def permitted_params
        params.require(:customer).permit(:email, :first_name, :last_name, :phone, :postcode, :address, :city, :country, :gender)
      end

      def set_customer
        @customer = @current_event.customers.find(params[:id])
        authorize @customer
      end

      def set_operator
        @operator_mode = params[:operator].eql?("true")
      end
    end
  end
end
