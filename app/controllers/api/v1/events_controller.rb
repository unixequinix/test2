class Api::V1::EventsController < Api::V1::BaseController
  def index
    @events = params[:filter].to_s.eql?("active") ? Event.where(state: :launched) : Event.all
    @events = @events.where(open_api: true)

    render(stats: :ok, json: @events, each_serializer: Api::V1::EventSerializer) if params[:mac].blank?

    begin
      device = Device.find_or_create_by!(mac: params[:mac])
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    status = device.asset_tracker.blank? ? :accepted : :ok

    render status: status, json: @events, each_serializer: Api::V1::EventSerializer
  end
end
