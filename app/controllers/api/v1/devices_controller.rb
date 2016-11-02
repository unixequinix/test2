class Api::V1::DevicesController < Api::BaseController
  def create
    device_atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    begin
      device = Device.find_or_create_by!(device_atts)
    rescue ActiveRecord::RecordNotUnique
      device = Device.find_by(device_atts)
    end

    render(json: :updated) && return if device.update(asset_tracker: params["asset_id"])
    render(status: :unprocessable_entity, json: device.errors.full_messages)
  end

  private

  def permitted_params
    params.require(:device).permit(:asset_tracker)
  end
end
