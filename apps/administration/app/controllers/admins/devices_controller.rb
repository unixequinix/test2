class Admins::DevicesController < Admins::BaseController
  def index
    set_presenter
  end

  def search
    set_presenter
    render :index
  end

  def show
    @device = Device.find(params[:id])
    @device_events = DeviceTransaction.where(device_uid: @device.mac)
                                      .includes(:event).group_by(&:event)
  end

  def update
    @device = Device.find(params[:id])
    if @device.update!(permitted_params)
      render json: @product
    else
      render status: :unprocessable_entity, json: :no_content
    end
  end

  def import # rubocop:disable Metrics/AbcSize
    alert = "Seleccione un archivo para importar"
    redirect_to(admins_devices_path, alert: alert) && return unless params[:file]
    lines = params[:file][:data].tempfile.map { |line| line.split(";") }
    lines.delete_at(0)

    lines.each do |asset_tracker, mac|
      device = Device.find_by_mac(mac)
      next unless device
      device.update!(asset_tracker: asset_tracker)
    end

    redirect_to(admins_devices_path, notice: "Device data updated")
  end

  private

  def permitted_params
    params.require(:device).permit(:device_model, :asset_tracker)
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Device".constantize.model_name,
      fetcher: Device.all,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: []
    )
  end
end
