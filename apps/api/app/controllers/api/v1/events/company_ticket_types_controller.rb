class Api::V1::Events::CompanyTicketTypesController < Api::V1::Events::BaseController
  def index
    render_entities("company_ticket_type")
  end
end
