module Api
  module V1
    class CustomersController < Api::BaseController
      def index
        @customers = Customer.all
        render json: @customers
      end
    end
  end
end
