module Api
  module V1
    class TicketsController < Api::BaseController
      def index
        @tickets = Ticket.all
        render json: @tickets
      end
    end
  end
end
