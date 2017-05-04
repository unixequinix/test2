class Api::V1::EventsController < Api::BaseController
  def index
    @events = params[:filter].to_s.eql?("active") ? Event.where(state: %w[started launched]) : Event.all

    device_atts = { mac: params[:mac] }
    begin
      device = Device.find_or_create_by!(device_atts)
    rescue ActiveRecord::RecordNotUnique
      device = Device.find_by(device_atts)
    end

    status = device.asset_tracker.blank? ? :accepted : :ok
    render status: status, json: @events, each_serializer: Api::V1::EventSerializer
  end
end
