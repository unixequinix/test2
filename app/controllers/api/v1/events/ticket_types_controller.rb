class Api::V1::Events::TicketTypesController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    types = @current_event.ticket_types.includes(company_event_agreement: :company).for_devices
    types = types.where("ticket_types.updated_at > ?", @modified) if @modified
    date = types.maximum(:updated_at)&.httpdate
    types = types.map { |a| Api::V1::TicketTypeSerializer.new(a) }.as_json if types.present?

    render_entity(types, date)
  end
end
