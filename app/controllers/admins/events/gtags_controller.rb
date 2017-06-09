class Admins::Events::GtagsController < Admins::Events::BaseController
  before_action :set_gtag, only: %i[show edit update destroy solve_inconsistent recalculate_balance]

  def index
    @q = @current_event.gtags.order(:tag_uid).ransack(params[:q])
    @gtags = @q.result
    authorize @gtags
    @gtags = @gtags.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Gtag.query_for_csv(@current_event))) }
    end
  end

  def show
    @transactions = @gtag.transactions.includes(:event).order(:gtag_counter)
  end

  def new
    @gtag = @current_event.gtags.new
    authorize @gtag
  end

  def create
    @gtag = @current_event.gtags.new(permitted_params)
    authorize @gtag
    if @gtag.save
      redirect_to admins_event_gtags_path, notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @gtag.update(permitted_params)
        format.html { redirect_to admins_event_gtag_path(@current_event, @gtag), notice: t("alerts.updated") }
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

  def solve_inconsistent
    @gtag.solve_inconsistent
    redirect_to admins_event_gtag_path(@current_event, @gtag), notice: "Gtag balance was made consistent"
  end

  def recalculate_balance
    @gtag.recalculate_balance
    redirect_to admins_event_gtag_path(@current_event, @gtag), notice: "Gtag balance was recalculated successfully"
  end

  def import # rubocop:disable Metrics/MethodLength
    authorize @current_event.gtags.new
    path = admins_event_gtags_path(@current_event)
    redirect_to(path, alert: "File not supplied") && return unless params[:file]
    file = params[:file][:data].tempfile.path
    company = @current_event.companies.find_or_create_by!(name: "Glownet")
    count = 0

    ticket_types = []
    CSV.foreach(file, headers: true, col_sep: ";") { |row| ticket_types << row.field("Type") }
    ticket_types = ticket_types.compact.uniq.map { |name| @current_event.ticket_types.find_or_create_by(name: name, company: company) }
    ticket_types = ticket_types.map { |tt| [tt.name, tt.id] }.to_h

    begin
      CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, _i|
        ticket_type = ticket_types[row.field("Type")]
        credits = row.field("Balance")
        GtagCreator.perform_later(event_id: @current_event.id, tag_uid: row.field("UID"), ticket_type_id: ticket_type, credits: credits)
        count += 1
      end
    rescue
      return redirect_to(path, alert: t("alerts.import.error"))
    end

    redirect_to(path, notice: t("alerts.import.delayed", count: count, item: "GTags"))
  end

  def sample_csv
    authorize @current_event.gtags.new
    header = %w[UID Balance Type]
    data = [%w[1218DECA31C9F92F 22.5 VIP], %w[E6312A015028B0FB General], %w[A43FE1C5E9A622C2]]

    csv_file = CsvExporter.sample(header, data)
    respond_to do |format|
      format.csv { send_data(csv_file) }
    end
  end

  private

  def set_gtag
    @gtag = @current_event.gtags.find(params[:id])
    authorize @gtag
  end

  def permitted_params
    params.require(:gtag).permit(:event_id, :tag_uid, :format, :redeemed, :banned, :ticket_type_id, :format, :active)
  end
end
