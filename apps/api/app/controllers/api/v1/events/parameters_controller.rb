module Api
  module V1
    module Events
      class ParametersController < Api::V1::Events::BaseController
        def index
          @parameters = EventParameter.includes(:parameter)
                           .where(event_id: current_event.id, parameters: { category: "device" })
          render json: @parameters, each_serializer: Api::V1::ParameterSerializer
        end
      end
    end
  end
end
