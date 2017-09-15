class Api::V2::Events::DevicesController < Api::V2::BaseController
  before_action :set_device, only: %i[show update destroy]

  # GET api/v2/events/:event_id/devices
  def index
    @devices = @current_event.devices
    authorize @devices

    paginate json: @devices
  end

  # GET api/v2/events/:event_id/devices/:id
  def show
    render json: @device, serializer: Api::V2::DeviceSerializer
  end

  # PATCH/PUT api/v2/events/:event_id/devices/:id
  def update
    if @device.update(device_params)
      render json: @device
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # DELETE api/v2/events/:event_id/devices/:id
  def destroy
    @current_event.device_registrations.find_by(device: @device).destroy
    head(:ok)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_device
    @device = @current_event.devices.find(params[:id])
    authorize @device
  end

  # Only allow a trusted parameter "white list" through.
  def device_params
    params.require(:device).permit(:mac, :asset_tracker)
  end
end
