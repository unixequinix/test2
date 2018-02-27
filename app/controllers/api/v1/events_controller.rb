class Api::V1::EventsController < Api::V1::BaseController
  def index
    device = Device.find_by(mac: params.slice(:mac).to_unsafe_h[:mac])

    if device.present? && device.team.present?
      status = device.asset_tracker.blank? ? :accepted : :ok
      events = [device.event].compact
      events = device.team.events.live if events.empty?

      render(status: status, json: events, serializer_params: { device: device })
    else
      render json: { error: "Device does not belong to a team" }, status: :unauthorized
    end
  end
end
