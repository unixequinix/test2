class Api::V1::Events::TicketTypesController < Api::V1::Events::BaseController
  def index
    render_entities("ticket_type")
  end
end
