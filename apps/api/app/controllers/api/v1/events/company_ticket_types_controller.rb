class Api::V1::Events::CompanyTicketTypesController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.company_ticket_types,
           each_serializer: Api::V1::CompanyTicketTypeSerializer
  end
end
