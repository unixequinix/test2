module Api
  module V1
    class EventsController < Api::BaseController
      def index
        @events = Event.all
        render json: @events
      end
    end
  end
end
