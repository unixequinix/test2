module Api
  module V1
    module Events
      class TimeController < Api::V1::Events::BaseController
        def index
          Time.use_zone(@current_event.timezone) do
            render plain: Time.current.as_json
          end
        end
      end
    end
  end
end
