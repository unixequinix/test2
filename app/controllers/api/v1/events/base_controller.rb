module Api
  module V1
    module Events
      class BaseController < Api::V1::BaseController
        before_action :set_event
        before_action :restrict_app_version
        before_action :check_api_open

        serialization_scope :current_event

        def render_entity(obj, date)
          response.headers["Last-Modified"] = date if date
          status = obj ? 200 : 304
          render(status: status, json: obj)
        end

        protected

        def set_modified
          @modified = Time.parse(request.headers["If-Modified-Since"]) if request.headers["If-Modified-Since"] # rubocop:disable Rails/TimeZone
        end

        private

        def set_event
          @current_event = Event.friendly.find(params[:event_id] || params[:id])
        end

        def restrict_app_version
          head(:upgrade_required, app_version: @current_event.app_version) unless @current_event.valid_app_version?(params[:app_version])
        end

        def check_api_open
          render json: { error: "API is closed for event '#{@current_event.name}'" }, status: :unauthorized unless @current_event.open_devices_api?
        end
      end
    end
  end
end
