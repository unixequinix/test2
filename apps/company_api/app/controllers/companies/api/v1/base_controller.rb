class Companies::Api::V1::BaseController < Companies::BaseController
  before_action :restrict_access_with_http
  attr_reader :current_event, :current_company

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)
      @current_company = Company.find_by(token: company_token, event: @current_event)
      @current_event && @current_company
    end
  end

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: ticket_type_id)
    ticket_type && ticket_type.company == @current_company &&
      ticket_type.event == @current_event && ticket_type.deleted_at.nil?
  end

  def validate_gtag_type!
    ticket_type_id = params[:gtag][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: params[:gtag][:ticket_type_id])
    ticket_type && ticket_type.company == @current_company &&
      ticket_type.event == @current_event && ticket_type.deleted_at.nil?
  end
end
