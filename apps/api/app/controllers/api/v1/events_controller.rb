class Api::V1::EventsController < Api::BaseController
  def index
    @events = if params[:filter] && params[:filter] == "active"
                Event.where(aasm_state: %w(started launched))
              else
                Event.all
              end

    atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    device = Device.find_or_create_by(mac: params[:mac])
    device.update(atts)

    status = device.asset_tracker ? :ok : :accepted
    render status: status, json: @events, each_serializer: Api::V1::EventSerializer
  end
end
