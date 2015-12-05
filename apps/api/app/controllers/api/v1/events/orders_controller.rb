module Api
  module V1
    module Events
      class OrdersController < Api::V1::Events::BaseController
        def index
          @orders = Order.joins(:customer_event_profile).where(customer_event_profiles: { event_id: current_event.id })
          render json: @orders
        end
      end
    end
  end
end
