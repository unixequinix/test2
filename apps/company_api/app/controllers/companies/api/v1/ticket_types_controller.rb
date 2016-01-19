module Companies
  module Api
    module V1
      class TicketTypesController < Companies::Api::BaseController
        def index
          @ticket_types = CompanyTicketType.includes(:company)
              .where(event_id: current_event, companies: { name: company_name })

          render json: {
            event_id: current_event,
            ticket_types: @ticket_types.map { |ticket_type|
              Companies::Api::V1::TicketTypeSerializer.new(ticket_type)
            }
          }
        end

        def show
          @ticket_type = CompanyTicketType.includes(:company)
              .find_by(id: params[:id], event_id: current_event, companies: { name: company_name })
              
          if @ticket_type
            render json: Companies::Api::V1::TicketTypeSerializer.new(@ticket_type)
          else
            render status: :not_found,
              json: { error: I18n.t("company_api.ticket_type.not_found", ticket_type_id: params[:id]) }
          end
        end
      end
    end
  end
end
