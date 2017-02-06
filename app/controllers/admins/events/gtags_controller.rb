class Admins::Events::GtagsController < Admins::Events::BaseController
  before_action :set_gtag, except: [:index, :new, :create]

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
    @gtag = Gtag.new
    authorize @gtag
  end

  def create
    @gtag = Gtag.new(permitted_params)
    authorize @gtag
    if @gtag.save
      redirect_to admins_event_gtags_path, notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    if @gtag.update(permitted_params)
      redirect_to admins_event_gtag_path(@current_event, @gtag), notice: t("alerts.updated")
    else
      flash.now[:alert] = t("alerts.error")
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @gtag.destroy
        format.html { redirect_to admins_event_gtags_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @gtag], alert: @gtag.errors.full_messages.to_sentence }
        format.json { render json: { errors: @gtag.errors.full_messages.to_sentence }, status: :unprocessable_entity }
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

  def ban
    @gtag.ban
    respond_to do |format|
      format.html { redirect_to admins_event_gtags_path, notice: t("alerts.updated") }
      format.json { render json: true }
    end
  end

  def unban
    @gtag.unban
    respond_to do |format|
      format.html { redirect_to admins_event_gtags_path, notice: t("alerts.updated") }
      format.json { render json: true }
    end
  end

  def import
    path = admins_event_gtags_path(@current_event)
    redirect_to(path, alert: "File not supplied") && return unless params[:file]
    file = params[:file][:data].tempfile.path

    begin
      CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, _i|
        tag = @current_event.gtags.find_or_create_by(tag_uid: row.field("tag_uid"))
        tag.update!(format: row.field("format"), loyalty: row.field("loyalty"))
      end
    rescue
      return redirect_to(path, alert: t("alerts.error"))
    end

    redirect_to(path, notice: "Gtags successfully imported")
  end

  def sample_csv
    header = %w(tag_uid format)
    data = [%w(1218DECA31C9F92F card), %w(E6312A015028B0FB wristband), %w(A43FE1C5E9A622C2 wristband)]

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
    params.require(:gtag).permit(:event_id, :tag_uid, :format, :redeemed, :banned, :loyalty, :ticket_type_id, :format)
  end
end
