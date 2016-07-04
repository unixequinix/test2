class Api::V1::DevicesController < Api::BaseController
  def update
    device = Device.find_by_mac(params[:id])
    render(json: :updated) && return if device.update(permitted_params)
    render(status: :unprocessable_entity, json: device.errors.full_messages)
  end

  private

  def permitted_params
    params.require(:device).permit(:asset_tracker)
  end
end
