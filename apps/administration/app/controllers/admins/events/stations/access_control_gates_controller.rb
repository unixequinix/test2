class Admins::Events::Stations::AccessControlGatesController < Admins::Events::BaseController
  before_action :set_params
  def index
    @gate = AccessControlGate.new
    set_presenter
  end

  def create
    query = { direction: permitted_params[:direction], access_id: permitted_params[:access_id] }
    render(nothing: true, status: 200) && return if AccessControlGate.find_by(query)
    @gate = AccessControlGate.create!(permitted_params)
  end

  def destroy
    @gate = @fetcher.access_control_gates.find(params[:id])
    @gate.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_station_access_control_gates_path(current_event, @station)
  end

  private

  def set_params
    @station = @fetcher.access_control_stations.find_by(id: params[:station_id])
    @accesses = @fetcher.accesses.map { |c| [c.catalog_item.name, c.id] }
  end

  def permitted_params
    params.require(:access_control_gate)
      .permit(:id, :direction, :access_id, station_parameter_attributes: [:id, :station_id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "AccessControlGate".constantize.model_name,
      fetcher: @fetcher.access_control_gates.joins(:station_parameter)
               .where(station_parameters: { station_id: params[:station_id] }),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:access],
      context: view_context
    )
  end
end
