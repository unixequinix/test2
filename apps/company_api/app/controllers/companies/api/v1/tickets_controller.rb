module Companies
  module Api
    module V1
      class TicketsController < Companies::Api::BaseController
        def index
          @tickets = Ticket.includes(:company_ticket_type, company_ticket_type: [:company])
                           .where(event_id: current_event, companies: { name: company_name })
          render json: {
            event_id: current_event,
            tickets: @tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
          }
        end

        def show
          @ticket = Ticket.includes(:company_ticket_type, company_ticket_type: [:company])
              .find_by(id: params[:id], event_id: current_event, companies: { name: company_name })

          if @ticket
            render json: @ticket
          else
            render status: :not_found,
              json: { error: I18n.t("company_api.tickets.not_found", ticket_id: params[:id]) }
          end
        end
      end
    end
  end
end
