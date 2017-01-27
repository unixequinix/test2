# rubocop:disable Metrics/ClassLength
class Admins::Events::GtagsController < Admins::Events::BaseController
  before_action :set_gtag, except: [:index, :new, :create]

  def index
    @gtags = @current_event.gtags.order(:tag_uid)
    authorize @gtags
    @gtags = @gtags.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Gtag.query_for_csv(@current_event))) }
    end
  end

  def show
    @transactions = @gtag.transactions.includes(:station).order(:gtag_counter)
  end

  def new
    @gtag = Gtag.new
    authorize @gtag
  end

  def create
    @gtag = Gtag.new(permitted_params)
    authorize @gtag
    if @gtag.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_gtags_path
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @gtag.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_path(@current_event, @gtag)
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @gtag.destroy
        format.html { redirect_to admins_event_gtags_path, notice: 'GTag was successfully deleted.' }
        format.json { render :show, status: :ok, location: admins_event_gtags_path }
      else
        redirect_to [:admins, @current_event, @gtag], error: @gtag.errors.full_messages.to_sentence
      end
    end
  end

  def destroy_multiple
    @gtags = params[:gtags]
    authorize @gtags
    if gtags
      @current_event.gtags.where(id: gtags.keys).each do |gtag|
        flash[:error] = gtag.errors.full_messages.join(". ") unless gtag.destroy
      end
    end
    redirect_to admins_event_gtags_path
  end

  def solve_inconsistent
    @gtag.solve_inconsistent
    redirect_to admins_event_gtag_path(@current_event, @gtag), notice: "Gtag balance was recalculated successfully"
  end

  def recalculate_balance
    @gtag.recalculate_balance
    redirect_to admins_event_gtag_path(@current_event, @gtag), notice: "Gtag balance was recalculated successfully"
  end

  def ban
    @gtag.update!(banned: true)
    redirect_to(admins_event_gtags_path)
  end

  def unban
    @gtag.update(banned: false)
    redirect_to(admins_event_gtags_path)
  end

  def import
    path = admins_event_gtags_path(@current_event)
    redirect_to(path, alert: t("admin.gtags.import.empty_file")) && return unless params[:file]
    file = params[:file][:data].tempfile.path

    begin
      CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, _i|
        tag = @current_event.gtags.find_or_create_by(tag_uid: row.field("tag_uid"))
        tag.update!(format: row.field("format"), loyalty: row.field("loyalty"))
      end
    rescue
      return redirect_to(path, alert: t("admin.gtags.import.error"))
    end

    redirect_to(path, notice: t("admin.gtags.import.success"))
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
