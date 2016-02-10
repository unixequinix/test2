module Api
  module V1
    module Events
      class ParametersController < Api::V1::Events::BaseController
        def index
          @gtag_type = EventParameter.with_event(current_event)
                       .find_by(parameters: { category: "gtag", group: "form", name: "gtag_type" })

          @parameters = EventParameter.with_event(current_event)
                        .joins(:parameter)
                        .where("(parameters.category = 'device') OR
                                  (parameters.category = 'gtag'
                                    AND parameters.group = '#{@gtag_type.value}')")

          result =  @parameters << @gtag_type
          render json: result, each_serializer: Api::V1::ParameterSerializer
        end
      end
    end
  end
end
