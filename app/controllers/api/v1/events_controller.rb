class Api::V1::EventsController < Api::V1::BaseController
  def index
    device = Device.find_by(mac: params[:mac])

    status = device&.asset_tracker.blank? ? :accepted : :ok

    if device.present? && device&.team.present?
      events = device.team.events.live.includes(:device_registrations)&.merge(DeviceRegistration.not_allowed)&.where(device_registrations: { device_id: device.id })

      render(status: status, json: events, serializer_params: { device: device }) && return if events.present?
      render json: { error: "Device has not any associated event" }, status: :unauthorized
    else
      render json: { error: "Device does not belong to a team" }, status: :unauthorized
    end
  end
end
