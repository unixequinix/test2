class Companies::Api::V1::BaseController < Companies::BaseController
  attr_reader :current_event, :agreement
  before_action :restrict_access_with_http

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)
      @agreement = @current_event&.company_event_agreements&.includes(:company)&.find_by(companies: { access_token: company_token })
      @current_event && @agreement || render(status: 403, json: :unauthorized)
    end
  end

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:ticket_type_id]
    return true unless ticket_type_id
    ticket_type = TicketType.find_by(id: ticket_type_id)
    ticket_type && ticket_type.company_event_agreement == agreement && ticket_type.event == @current_event
  end

  def validate_gtag_type!
    ticket_type_id = params[:gtag][:ticket_type_id]
    return true unless ticket_type_id
    ticket_type = TicketType.find_by(id: params[:gtag][:ticket_type_id])
    ticket_type && ticket_type.company_event_agreement == agreement && ticket_type.event == @current_event
  end

  def ticket_types
    @current_event.ticket_types.where(company_event_agreement: @agreement.id)
  end

  def tickets
    @current_event.tickets.joins(ticket_type: :company_event_agreement).where(ticket_types: { company_event_agreement_id: @agreement.id })
  end

  def banned_tickets
    tickets.where(banned: true)
  end
end
