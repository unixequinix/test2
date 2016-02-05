module Companies
  module Api
    module V1
      class BannedTicketsController < Companies::Api::V1::BaseController
        def index
          @banned_tickets = Ticket.banned
                                  .search_by_company_and_event(current_company.name, current_event)

          render json: {
            event_id: current_event.id,
            blacklisted_tickets: @banned_tickets.map do |ticket|
              Companies::Api::V1::TicketSerializer.new(ticket)
            end
          }
        end

        def create
          @banned_ticket = BannedTicket.new(banned_ticket_params)

          assign = CredentialAssignment.find_by(credentiable_id: banned_ticket_params[:ticket_id],
                                                credentiable_type: "Ticket")


          BannedCustomerEventProfile.new(assign.customer_event_profile_id) unless assign.nil?

          if @banned_ticket.save
            render status: :created, json: @banned_ticket
          else
            render status: :bad_request,
                   json: { message: I18n.t("company_api.tickets.bad_request"),
                           errors: @banned_ticket.errors }
          end
        end

        def destroy
          @banned_ticket = BannedTicket.includes(:ticket)
                                       .find_by(tickets: { code: params[:id],
                                                           event_id: current_event.id })

          render(status: :not_found, json: :not_found) && return if @banned_ticket.nil?
          render(status: :internal_server_error, json: :internal_server_error) && return unless @banned_ticket.destroy
          render(status: :no_content, json: :no_content)
        end

        private

        def banned_ticket_params
          ticket_id = Ticket.select(:id).find_by(code: params[:ticket_blacklist][:ticket_reference]).id
          params[:ticket_blacklist][:ticket_id] = ticket_id
          params.require(:ticket_blacklist).permit(:ticket_id)
        end
      end
    end
  end
end
