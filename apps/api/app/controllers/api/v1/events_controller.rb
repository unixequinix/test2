class Api::V1::EventsController < Api::BaseController
  def index
    @events = if params[:filter] && params[:filter] == "active"
                Event.where(aasm_state: %w(started launched))
              else
                Event.all
              end

    atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    Device.find_or_create_by(atts)
    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
