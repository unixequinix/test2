module Api
  module V1
    class RefundsController < Api::BaseController
      def index
        @refunds = Refund.all
        render json: @refunds
      end
    end
  end
end
