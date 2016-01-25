module Companies
  module Api
    module V1
      class BlacklistsController < Companies::Api::V1::BaseController
        def index
          @tickets = Ticket.blacklisted
                           .search_by_company_and_event(current_company.name, current_event)

          render json: {
            event_id: current_event.id,
            blacklisted_tickets: @tickets.map { |ticket| Companies::Api::V1::TicketSerializer.new(ticket) }
          }
        end

        def create
          @ticket = TicketBlacklist.new(ticket_blacklist_params)

          if @ticket.save
            render json: @ticket
          else
            render status: :bad_request,
                   json: { message: I18n.t("company_api.tickets.bad_request"), errors: @ticket.errors }
          end
        end

        def destroy
          @ticket = Ticket.blacklisted
                          .search_by_company_and_event(current_company.name, current_event)
                          .find_by(code: params[:id])
                          .ticket_blacklist

          render status: :no_content, json: :no_content if @ticket.destroy
        end

        private

        def ticket_blacklist_params
          params[:blacklist][:ticket_id] = Ticket.find_by(code: params[:blacklist][:ticket_reference]).id
          params.require(:blacklist).permit(:ticket_id)
        end
      end
    end
  end
end
