module Api
  module V1
    module Events
      class CustomerEventProfilesController < Api::V1::Events::BaseController
        def index
          @customer_event_profiles = CustomerEventProfile.where(event_id: current_event.id)
          render json: Api::V1::EventCustomersSerializer.new(@customer_event_profiles, root: false)
        end
      end
    end
  end
end
