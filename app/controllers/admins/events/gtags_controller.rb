module Admins
  module Events
    class GtagsController < Admins::Events::BaseController
      before_action :set_gtag, only: %i[show edit update destroy solve_inconsistent recalculate_balance merge make_active]
      before_action :set_operator, only: %i[index new import]

      def index
        @q = @current_event.gtags.where(operator: @operator_mode).includes(:customer).order(:tag_uid).ransack(params[:q])
        @gtags = @q.result
        authorize @gtags
        @gtags = @gtags.page(params[:page])

        @stable = @gtags.where(consistent: true, complete: true)
        @inconsistent = @gtags.where(consistent: false)
        @incomplete = @gtags.where(complete: false)

        respond_to do |format|
          format.html
          format.csv { send_data(CsvExporter.to_csv(Gtag.query_for_csv(@current_event, @operator_mode))) }
        end
      end

      def show
        @corrections = @gtag.transactions.where(action: "correction")
        @transactions = @gtag.transactions.includes(:event).debug
      end

      def new
        @gtag = @current_event.gtags.new(operator: @operator_mode)
        authorize @gtag
      end

      def create
        @gtag = @current_event.gtags.new(permitted_params)
        authorize @gtag
        if @gtag.save
          redirect_to admins_event_gtags_path(operator: @gtag.operator?), notice: t("alerts.created")
        else
          @operator_mode = @gtag.operator?
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def edit
        @operator_mode = @gtag.operator?
      end

      def update
        @operator_mode = @gtag.operator?
        respond_to do |format|
          if @gtag.update(permitted_params)
            format.html { redirect_to [:admins, @current_event, @gtag], notice: t("alerts.updated") }
            format.json { render json: @gtag }
          else
            flash.now[:alert] = t("alerts.error")
            format.html { render :edit }
            format.json { render json: @gtag.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        respond_to do |format|
          if @gtag.destroy
            format.html { redirect_to admins_event_gtags_path, notice: t("alerts.destroyed") }
            format.json { render json: true }
          else
            format.html { redirect_to [:admins, @current_event, @gtag], alert: @gtag.errors.full_messages.to_sentence }
            format.json { render json: { errors: @gtag.errors }, status: :unprocessable_entity }
          end
        end
      end

      def merge
        admission = Admission.find(@current_event, params[:adm_id], params[:adm_class])
        result = @gtag.merge(admission)

        @gtag.reload.customer.validate_gtags

        alert = result.present? ? { notice: "Admissions were sucessfully merged" } : { alert: "Admissions could not be merged" }
        redirect_to [:admins, @current_event, (result || admission)], alert
      end

      def inconsistencies
        @q = @current_event.gtags.inconsistent.order(:tag_uid).ransack(params[:q])
        @gtags = @q.result
        authorize @gtags
        @gtags = @gtags.page(params[:page])
      end

      def missing_transactions
        @q = @current_event.gtags.missing_transactions.order(:tag_uid).ransack(params[:q])
        @gtags = @q.result
        authorize @gtags
        @gtags = @gtags.page(params[:page])
      end

      def solve_inconsistent
        @gtag.update!(consistent: true)
        redirect_to [:admins, @current_event, @gtag], notice: "Gtag balance was made consistent"
      end

      def recalculate_balance
        @gtag.recalculate_all
        redirect_to [:admins, @current_event, @gtag], notice: "Gtag balance was recalculated successfully"
      end

      def make_active
        @gtag.make_active! if @gtag.customer
        alert = @gtag.customer.present? ? { notice: "Gtag is active now" } : { alert: "Gtag could not be activated" }
        redirect_to [:admins, @current_event, (@gtag.customer || @gtag)], alert
      end

      def import
        authorize @current_event.gtags.new
        url = [:admins, @current_event, :gtags, operator: @operator_mode]

        redirect_to(url, alert: "File not supplied") && return unless params[:file]
        file = params[:file][:data].tempfile.path
        count = 0

        ticket_types = []
        CSV.foreach(file, headers: true, col_sep: ";") { |row| ticket_types << row.field("Type") }
        ticket_types = ticket_types.compact.uniq.map { |name| @current_event.ticket_types.find_or_create_by!(name: name) }.map { |tt| [tt.name, tt.id] }.to_h

        begin
          CSV.foreach(file, headers: true, col_sep: ";") do |row|
            Creators::GtagJob.perform_later(@current_event, row.field("UID"), row.field("Balance"), row.field("VirtualBalance"), operator: @operator_mode, ticket_type_id: ticket_types[row.field("Type")])
            count += 1
          end
        rescue StandardError
          return redirect_to(url, alert: t("alerts.import.error"))
        end

        redirect_to(url, notice: t("alerts.import.delayed", count: count, item: "GTags"))
      end

      def sample_csv
        authorize @current_event.gtags.new

        csv_file = CsvExporter.sample(%w[UID Type Balance VirtualBalance], [%w[15GH56YTD4F6 VIP 22.5], %w[25GH56YTD4F6 General 0 10], %w[35GH56YTD4F6]])
        respond_to do |format|
          format.csv { send_data(csv_file) }
        end
      end

      private

      def set_gtag
        @gtag = @current_event.gtags.find(params[:id])
        authorize @gtag
      end

      def set_operator
        @operator_mode = params[:operator].eql?("true")
      end

      def permitted_params
        params.require(:gtag).permit(:tag_uid, :format, :redeemed, :banned, :ticket_type_id, :format, :active, :operator)
      end
    end
  end
end
