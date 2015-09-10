module Api
  module V1
    module Events
      class RefundsController < Api::V1::Events::BaseController
        def index
          @refunds = Refund.joins(:customer_event_profile).where(customer_event_profiles: { event_id: current_event.id }).where(aasm_state: :created)
          render json: @refunds
        end
      end
    end
  end
end
