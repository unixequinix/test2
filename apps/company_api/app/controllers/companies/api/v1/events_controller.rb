module Companies
  module Api
    module V1
      class EventsController < Companies::Api::BaseController
        def index
          @events = Event.all
          render json: @events
        end
      end
    end
  end
end
