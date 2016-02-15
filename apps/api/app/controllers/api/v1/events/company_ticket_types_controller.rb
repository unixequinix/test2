class Api::V1::Events::CompanyTicketTypesController < Api::V1::Events::BaseController
  def index
    @ticket_types = CompanyTicketType.includes(:company).where(event_id: current_event.id)
    render json: @ticket_types, each_serializer: Api::V1::CompanyTicketTypeSerializer
  end
end
