module Api
  module V1
    module Events
      class CustomersController < Api::V1::Events::BaseController
        def index
          @cep = CustomerEventProfile.includes(:customer, :credential_assignments, :orders)
                                     .where(event_id: current_event.id)
          render json: @cep, each_serializer: Api::V1::CustomerEventProfileSerializer
        end
      end
    end
  end
end
