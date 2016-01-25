module Companies
  module Api
    module V1
      class BannedTicketsController < Companies::Api::V1::BaseController
        def index
          @banned_tickets = Ticket.banned
                                  .search_by_company_and_event(current_company.name, current_event)

          render json: {
            event_id: current_event.id,
            banned_tickets: @banned_tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
          }
        end

        def create
          @banned_ticket = BannedTicket.new(banned_ticket_params)

          if @banned_ticket.save
            render status: :created, json: @banned_ticket
          else
            render status: :bad_request,
                   json: { message: I18n.t("company_api.tickets.bad_request"), errors: @ticket.errors }
          end
        end

        def destroy
          @banned_ticket = BannedTicket.includes(:ticket)
                                       .find_by(tickets: { code: params[:id], event_id: current_event.id })

          if @banned_ticket.present? && @banned_ticket.destroy
            render status: :no_content, json: :no_content
          else
            render status: :not_found,
                   json: { message: I18n.t("company_api.tickets.not_found", ticket_id: params[:id]) }
          end
        end

        private

        def banned_ticket_params
          params[:banned_ticket][:ticket_id] = Ticket.find_by(code: params[:banned_ticket][:ticket_reference]).id
          params.require(:banned_ticket).permit(:ticket_id)
        end
      end
    end
  end
end
