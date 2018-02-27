class Api::V1::DevicesController < Api::V1::BaseController
  def create
    Creators::DeviceJob.perform_later(params.slice(:mac, :team_id).to_unsafe_h, params[:asset_id])
    render(json: :updated)
  end
end
