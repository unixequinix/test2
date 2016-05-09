class Admins::Events::Stations::AccessControlGatesController < Admins::Events::BaseController
  before_action :set_params
  def index
    @gate = AccessControlGate.new
    set_presenter
  end

  def create
    accesses = @station.access_control_gates.map(&:access_id)

    if accesses.include?(permitted_params[:access_id].to_i)
      flash[:alert] = I18n.t("alerts.access_only_one_way")
    else
      @gate = AccessControlGate.create!(permitted_params)
    end
    redirect_to admins_event_station_access_control_gates_path(current_event, @station)
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
