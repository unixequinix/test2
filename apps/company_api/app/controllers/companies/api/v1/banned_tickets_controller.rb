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
                   json: { message: I18n.t("company_api.tickets.bad_request"), errors: @banned_ticket.errors }
          end
        end

        def destroy
          @banned_ticket = BannedTicket.includes(:ticket)
                                       .find_by(tickets: { code: params[:id], event_id: current_event.id })

          render(status: :not_found, json: :not_found) && return if @banned_ticket.nil?
          render(status: :internal_server_error, json: :internal_server_error) && return unless @banned_ticket.destroy
          render(status: :no_content, json: :no_content)
        end

        private

        def banned_ticket_params
          ticket_id = Ticket.find_by(code: params[:banned_ticket][:ticket_reference]).select(:id).id
          params[:banned_ticket][:ticket_id] = ticket_id
          params.require(:banned_ticket).permit(:ticket_id)
        end
      end
    end
  end
end
