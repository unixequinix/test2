module Api
  module V1
    class CustomersController < Api::BaseController
      def index
        @customers = Customer.all
        # render json: @customers
        render json: Api::V1::EventCustomersSerializer.new(@customers)
      end
    end
  end
end
