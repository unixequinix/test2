module Api
  module V1
    class OrdersController < Api::BaseController
      def index
        @orders = Order.all
        render json: @orders
      end
    end
  end
end
