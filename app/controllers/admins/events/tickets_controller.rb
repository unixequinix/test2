module Admins
  module Events
    class TicketsController < Admins::Events::BaseController
      before_action :set_ticket, except: %i[index new create import sample_csv]

      def index
        @q = @current_event.tickets.includes(:customer, :ticket_type).order(created_at: :desc).ransack(params[:q])
        @tickets = @q.result
        authorize @tickets
        @tickets = @tickets.page(params[:page])

        respond_to do |format|
          format.html
          format.csv { send_data(CsvExporter.to_csv(Ticket.query_for_csv(@current_event))) }
        end
      end

      def show
        @catalog_item = @ticket.ticket_type&.catalog_item
        @transactions = @ticket.transactions.debug
      end

      def new
        @ticket = @current_event.tickets.new
        authorize @ticket
      end

      def create
        @ticket = @current_event.tickets.new(permitted_params)
        authorize @ticket
        if @ticket.save
          redirect_to [:admins, @current_event, @ticket], notice: t("alerts.created")
        else
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def update
        respond_to do |format|
          if @ticket.update(permitted_params)
            format.html { redirect_to admins_event_ticket_path(@current_event, @ticket), notice: t("alerts.updated") }
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
            format.html { redirect_to admins_event_tickets_path, notice: 'Ticket was successfully deleted.' }
            format.json { render :show, location: admins_event_tickets_path }
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
        path = admins_event_tickets_path(@current_event)
        redirect_to(path, alert: t("admin.tickets.import.empty_file")) && return unless params[:file]
        file = params[:file][:data].tempfile.path
        count = 0

        begin
          ticket_types = []
          CSV.foreach(file, headers: true, col_sep: ";") { |row| ticket_types << row.field("ticket_type") }
          ticket_types = ticket_types.compact.uniq.map { |name| @current_event.ticket_types.find_or_create_by(name: name) }
          ticket_types = ticket_types.map { |tt| [tt.name, tt.id] }.to_h

          CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, _i|
            ticket_atts = { event_id: @current_event.id, code: row.field("reference"), ticket_type_id: ticket_types[row.field("ticket_type")], purchaser_first_name: row.field("first_name"), purchaser_last_name: row.field("last_name"), purchaser_email: row.field("email") }
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
        header = %w[ticket_type reference first_name last_name email]
        data = [["VIP Night", "0011223344", "Jon", "Snow", "jon@snow.com"], ["VIP Day", "4433221100", "Arya", "Stark", "arya@stark.com"]]

        respond_to do |format|
          format.csv { send_data(CsvExporter.sample(header, data)) }
        end
      end

      def ban
        @ticket.ban
        respond_to do |format|
          format.html { redirect_to admins_event_tickets_path, notice: t("alerts.updated") }
          format.json { render json: true }
        end
      end

      def unban
        @ticket.unban
        respond_to do |format|
          format.html { redirect_to admins_event_tickets_path, notice: t("alerts.updated") }
          format.json { render json: true }
        end
      end

      private

      def set_ticket
        @ticket = @current_event.tickets.find(params[:id])
        authorize @ticket
      end

      def permitted_params
        params.require(:ticket).permit(:code, :ticket_type_id, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :catalog_item_id)
      end
    end
  end
end
