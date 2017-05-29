class Companies::Api::V1::BaseController < Companies::BaseController
  attr_reader :current_event
  before_action :restrict_access_with_http

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)
      @company = @current_event&.companies&.find_by(access_token: company_token)
      @current_event && @company && @current_event.launched? || render(status: 403, json: :unauthorized)
    end
  end

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:ticket_type_id]
    return true unless ticket_type_id
    @current_event.ticket_types.find_by(id: ticket_type_id, company: @company)
  end

  def ticket_types
    @company.ticket_types
  end

  def tickets
    @current_event.tickets.joins(:ticket_type).where(ticket_types: { company_id: @company.id })
  end

  def banned_tickets
    tickets.where(banned: true)
  end
end
