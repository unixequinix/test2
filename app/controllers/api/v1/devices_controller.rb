class Api::V1::DevicesController < Api::V1::BaseController
  def create
    DeviceCreator.perform_later(params.slice(:mac).to_unsafe_h, params[:asset_id])
    render(json: :updated)
  end
end
