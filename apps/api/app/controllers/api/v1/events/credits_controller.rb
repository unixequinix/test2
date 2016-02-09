module Api
  module V1
    module Events
      class CreditsController < Api::V1::Events::BaseController
        def index
          @credits = Credit.for_event(current_event)
          render json: @credits
        end
      end
    end
  end
end
