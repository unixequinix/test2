module Api
  module V1
    module Events
      class TicketsController < Api::V1::Events::BaseController
        def index
          @tickets = Ticket.where(event_id: current_event.id)
          render json: @tickets
        end
      end
    end
  end
end
