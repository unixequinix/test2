class Admins::Events::GtagsController < Admins::Events::CheckinBaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(Gtag.selected_data(current_event.id))) }
    end
  end

  def search
    render :index
  end

  def show
    @gtag = @fetcher.gtags.includes(credential_assignments: :customer_event_profile).find(params[:id])
  end

  def new
    @gtag = Gtag.new
    @gtag.build_gtag_credit_log
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @gtag = @fetcher.gtags.find(params[:id])
    @gtag.build_gtag_credit_log unless @gtag.gtag_credit_log
  end

  def update
    @gtag = @fetcher.gtags.find(params[:id])
    if @gtag.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_url(current_event, @gtag)
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @gtag = @fetcher.gtags.find(params[:id])
    if @gtag.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      redirect_to admins_event_gtags_url
    end
  end

  def destroy_multiple
    gtags = params[:gtags]
    if gtags
      @fetcher.gtags.where(id: gtags.keys).each do |gtag|
        flash[:error] = gtag.errors.full_messages.join(". ") unless gtag.destroy
      end
    end
    redirect_to admins_event_gtags_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Gtag".constantize.model_name,
      fetcher: @fetcher.gtags,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:assigned_gtag_credential, :gtag_credit_log],
      context: view_context
    )
  end

  def permitted_params
    params.require(:gtag).permit(
      :event_id,
      :tag_uid,
      :tag_serial_number,
      gtag_credit_log_attributes: [:id, :gtag_id, :amount, :_destroy])
  end
end
