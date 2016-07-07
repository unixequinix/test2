class Api::V1::DevicesController < Api::BaseController
  def create
    device = Device.find_by(mac: params["mac"], imei: params["imei"], serial_number: params["serial_number"])
    render(json: :updated) && return if device.update(asset_tracker: params["asset_id"])
    render(status: :unprocessable_entity, json: device.errors.full_messages)
  end

  private

  def permitted_params
    params.require(:device).permit(:asset_tracker)
  end
end
