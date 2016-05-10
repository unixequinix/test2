class Admins::Events::Stations::TopupCreditsController < Admins::Events::BaseController
  before_action :set_params
  def index
    @topup_credit = TopupCredit.new
    set_presenter
  end

  def create
    @topup_credit = TopupCredit.new(permitted_params)
  end

  def destroy
    @topup_credit = @fetcher.topup_credits.find(params[:id])
    @topup_credit.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_station_topup_credits_url(current_event, @station)
  end

  private

  def set_params
    @station = @fetcher.topup_stations.find_by(id: params[:station_id])
    @credits = @fetcher.credits.includes(:catalog_item).map { |c| [c.catalog_item.name, c.id] }
  end

  def permitted_params
    params.require(:topup_credit)
          .permit(:id, :amount, :credit_id, station_parameter_attributes: [:id, :station_id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "TopupCredit".constantize.model_name,
      fetcher: @fetcher.topup_credits.joins(:station_parameter)
               .where(station_parameters: { station_id: params[:station_id] }),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:credit],
      context: view_context
    )
  end
end
