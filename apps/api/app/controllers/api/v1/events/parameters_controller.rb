module Api
  module V1
    module Events
      class ParametersController < Api::V1::Events::BaseController
        def index
          @gtag_type = EventParameter.with_event(current_event)
                        .where(parameters: { category: "gtag", group: "form", name: "gtag_type" })
                        
          @gtag_params = EventParameter.with_event(current_event)
                          .where(parameters: { category: "gtag", group: @gtag_type.first.value })

          @device_params = EventParameter.with_event(current_event)
                            .where(parameters: { category: "device" })

          result = @device_params + @gtag_type + @gtag_params
          render json: result, each_serializer: Api::V1::ParameterSerializer
        end
      end
    end
  end
end
