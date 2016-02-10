module Api
  module V1
    module Events
      class PreeventProductsController < Api::V1::Events::BaseController
        def index
          @products = PreeventProduct.includes(:preevent_items)
                      .where(event_id: current_event.id)

          render json: @products, each_serializer: Api::V1::PreeventProductSerializer
        end
      end
    end
  end
end
