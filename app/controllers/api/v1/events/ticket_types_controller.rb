class Api::V1::Events::TicketTypesController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    ticket_types = current_event.ticket_types.includes(company_event_agreement: :company)
    ticket_types = ticket_types.where("ticket_types.updated_at > ?", @modified) if @modified
    date = ticket_types.maximum(:updated_at)&.httpdate
    ticket_types = ActiveModelSerializers::Adapter.create(ticket_types.map { |a| Api::V1::TicketTypeSerializer.new(a) }).to_json if ticket_types.present? # rubocop:disable Metrics/LineLength

    render_entity(ticket_types, date)
  end
end
