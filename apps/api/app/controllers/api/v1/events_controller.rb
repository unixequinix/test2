class Api::V1::EventsController < Api::BaseController
  def index
    @events = if params[:filter] && params[:filter] == "active"
                Event.where(aasm_state: %w(started launched))
              else
                Event.all
              end

    atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    device = Device.find_by(mac: params[:mac])
    device.update(atts)

    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
