class Api::V1::EventsController < Api::BaseController
  def index
    @events = if params[:filter] && params[:filter] == "active"
                Event.where(aasm_state: %w(started launched))
              else
                Event.all
              end

    device_atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    begin
      device = Device.find_or_create_by!(device_atts)
    rescue ActiveRecord::RecordNotUnique
      device = Device.find_by(device_atts)
    end

    status = device.asset_tracker.blank? ? :accepted : :ok
    render status: status, json: @events, each_serializer: Api::V1::EventSerializer
  end
end