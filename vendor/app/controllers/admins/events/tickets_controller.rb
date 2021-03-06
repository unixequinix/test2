module Admins
  module Events
    class TicketsController < Admins::Events::BaseController
      before_action :set_ticket, except: %i[index new create import sample_csv]
      before_action :set_operator, only: %i[index new import]

      def index
        @q = @current_event.tickets.where(operator: @operator_mode).includes(:customer, :ticket_type).order(created_at: :desc).ransack(params[:q])
        @tickets = @q.result
        authorize @tickets
        @tickets = @tickets.page(params[:page])

        respond_to do |format|
          format.html
          format.csv { send_data(CsvExporter.to_csv(Ticket.query_for_csv(@current_event, @operator_mode))) }
        end
      end

      def show
        @catalog_item = @ticket.ticket_type&.catalog_item
        @transactions = @ticket.transactions.debug
      end

      def new
        @ticket = @current_event.tickets.new(operator: @operator_mode)
        authorize @ticket
      end

      def create
        @ticket = @current_event.tickets.new(permitted_params)
        authorize @ticket
        if @ticket.save
          redirect_to [:admins, @current_event, @ticket, operator: @ticket.operator?], notice: t("alerts.created")
        else
          @operator_mode = @ticket.operator?
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def edit
        @operator_mode = @ticket.operator?
      end

      def update
        @operator_mode = @ticket.operator?
        respond_to do |format|
          if @ticket.update(permitted_params)
            format.html { redirect_to [:admins, @current_event, @ticket], notice: t("alerts.updated") }
            format.json { render status: :ok, json: @ticket }
          else
            format.html { render :edit }
            format.json { render json: @ticket.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        respond_to do |format|
          if @ticket.destroy
            format.html { redirect_to [:admins, @current_event, :tickets, operator: @ticket.operator?], notice: 'Ticket was successfully deleted.' }
            format.json { render :show, location: [:admins, @current_event, :tickets, operator: @ticket.operator?] }
          else
            redirect_to [:admins, @current_event, @ticket], alert: @ticket.errors.full_messages.to_sentence
          end
        end
      end

      def merge
        admission = Admission.find(@current_event, params[:adm_id], params[:adm_class])
        result = @ticket.merge(admission)

        @ticket.reload.customer.validate_gtags

        alert = result.present? ? { notice: "Admissions were sucessfully merged" } : { alert: "Admissions could not be merged" }
        redirect_to [:admins, @current_event, (result || admission)], alert
      end

      def import
        authorize @current_event.tickets.new
        path = [:admins, @current_event, :tickets, operator: @operator_mode]
        redirect_to(path, alert: t("alerts.import.empty_file")) && return unless params[:file]
        file = params[:file][:data].tempfile.path
        count = 0

        begin
          ticket_types = []
          CSV.foreach(file, headers: true, col_sep: ";") { |row| ticket_types << [row.field("ticket_type"), row.field("company")] }
          ticket_types = ticket_types.compact.uniq.map { |name, company| @current_event.ticket_types.find_or_create_by(name: name, company: company, operator: @operator_mode) }
          ticket_types = ticket_types.map { |tt| [tt.name, tt.id] }.to_h

          CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, _i|
            ticket_atts = { event_id: @current_event.id, code: row.field("reference"), ticket_type_id: ticket_types[row.field("ticket_type")], operator: @operator_mode, purchaser_first_name: row.field("first_name"), purchaser_last_name: row.field("last_name"), purchaser_email: row.field("email") }
            Creators::TicketJob.perform_later(ticket_atts)
            count += 1
          end
        rescue StandardError
          return redirect_to(path, alert: t("alerts.import.error"))
        end

        redirect_to(path, notice: t("alerts.import.delayed", count: count, item: "Tickets"))
      end

      def sample_csv
        authorize @current_event.tickets.new
        header = %w[company ticket_type reference first_name last_name email]
        data = [["Ticket Company1", "VIP Night", "0011223344", "Jon", "Snow", "jon@snow.com"], ["Ticket Company1", "VIP Day", "4433221100", "Arya", "Stark", "arya@stark.com"]]

        respond_to do |format|
          format.csv { send_data(CsvExporter.sample(header, data)) }
        end
      end

      def ban
        @ticket.ban
        respond_to do |format|
          format.html { redirect_to [:admins, @current_event, :tickets, operator: @ticket.operator?], notice: t("alerts.updated") }
          format.json { render json: true }
        end
      end

      def unban
        @ticket.unban
        respond_to do |format|
          format.html { redirect_to [:admins, @current_event, :tickets, operator: @ticket.operator?], notice: t("alerts.updated") }
          format.json { render json: true }
        end
      end

      private

      def set_ticket
        @ticket = @current_event.tickets.find(params[:id])
        authorize @ticket
      end

      def set_operator
        @operator_mode = params[:operator].eql?("true")
      end

      def permitted_params
        params.require(:ticket).permit(:code, :ticket_type_id, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :catalog_item_id, :operator)
      end
    end
  end
end
