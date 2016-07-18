class Admins::DevicesController < Admins::BaseController
  def index
    @devices = params[:filter].nil? ? Device.all : Device.where("substr(asset_tracker, 1, 1) = ?", params[:filter])
    @devices = @devices.page(params[:page])
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

  private

  def permitted_params
    params.require(:device).permit(:device_model, :asset_tracker)
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Device".constantize.model_name,
      fetcher: @devices,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: []
    )
  end
end
