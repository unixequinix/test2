module Api
  module V1
    class RefundsController < Api::BaseController
      def index
        @refunds = Refund.where(aasm_state: :created)
        render json: @refunds
      end
    end
  end
end
