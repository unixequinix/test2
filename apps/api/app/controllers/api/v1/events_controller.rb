class Api::V1::EventsController < Api::BaseController
  def index
    if params[:filter] && params[:filter] == "active"
      @events = Event.where(aasm_state: %w(started launched))
    else
      @events = Event.all
    end

    atts = { imei: params[:imei], mac: params[:mac], serial_number: params[:serial_number] }
    Device.find_or_create_by(atts)

    render json: @events, each_serializer: Api::V1::EventSerializer
  end
end
