module Api
  module V1
    module Events
      class BaseController < Api::BaseController
        helper_method :current_event
        before_action :fetch_current_event

        def current_event
          @current_event || Event.new
        end

        private

        def fetch_current_event
          id = params[:event_id] || params[:id]
          @current_event = Event.friendly.find(id)
        end
      end
    end
  end
end
