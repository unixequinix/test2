# rubocop:disable Metrics/ClassLength
class Admins::Events::GtagsController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]
  before_action :set_gtag, only: [:show, :edit, :update, :destroy, :ban, :unban, :recalculate_balance, :solve_inconsistent]

  def index
    respond_to do |format|
      format.html
      format.csv do
        gtags = Gtag.query_for_csv(@current_event)
        redirect_to(admins_event_gtags_path(@current_event)) && return if gtags.empty?

        send_data(CsvExporter.to_csv(gtags))
      end
    end
  end

  def show
    @transactions = @gtag.transactions.includes(:station).order(:gtag_counter)
  end

  def search
    render :index
  end

  def new
    @gtag = Gtag.new
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_gtags_url
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @gtag.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_url(@current_event, @gtag)
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @gtag.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
    end
    redirect_to admins_event_gtags_url
  end

  def destroy_multiple
    gtags = params[:gtags]
    if gtags
      @current_event.gtags.where(id: gtags.keys).each do |gtag|
        flash[:error] = gtag.errors.full_messages.join(". ") unless gtag.destroy
      end
    end
    redirect_to admins_event_gtags_url
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
    # TODO: Refactor this when gtag blacklisting is defined
    update_blacklist
    redirect_to(admins_event_gtags_url)
  end

  def unban
    @gtag.update(banned: false)
    # TODO: Refactor this when gtag blacklisting is defined
    update_blacklist
    redirect_to(admins_event_gtags_url)
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
    header = %w(tag_uid format loyalty)
    data = [%w(1218DECA31C9F92F card true),
            %w(E6312A015028B0FB wristband false),
            %w(A43FE1C5E9A622C2 wristband true)]

    csv_file = CsvExporter.sample(header, data)
    respond_to do |format|
      format.csv { send_data(csv_file) }
    end
  end

  private

  # TODO: Refactor this when gtag blacklisting is defined
  def update_blacklist
    atts = @current_event.device_settings
    atts[:gtag_blacklist] = @current_event.gtags.banned.pluck(:tag_uid).join(",")
    @current_event.update(device_settings: atts)
  end

  def set_gtag
    @gtag = @current_event.gtags.find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Gtag".constantize.model_name,
      fetcher: @current_event.gtags,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [
        customer: :tickets
      ],
      context: view_context
    )
  end

  def permitted_params
    params.require(:gtag).permit(
      :event_id,
      :tag_uid,
      :format,
      :redeemed,
      :banned,
      :loyalty,
      :ticket_type_id,
      :format
    )
  end
end
