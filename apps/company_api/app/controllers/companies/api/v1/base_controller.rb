class Companies::Api::V1::BaseController < Companies::BaseController
  attr_reader :current_event, :agreement
  before_action :restrict_access_with_http
  before_filter :enable_fetcher

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)

      @agreement = @current_event.company_event_agreements
                   .includes(:company)
                   .find_by(companies: { access_token: company_token }) if @current_event
      @current_event && @agreement || render(status: 403, json: :unauthorized)
    end
  end

  def enable_fetcher
    @fetcher = Multitenancy::CompanyFetcher.new(current_event, agreement)
  end

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: ticket_type_id)
    ticket_type && ticket_type.company_event_agreement == agreement &&
      ticket_type.event == current_event && ticket_type.deleted_at.nil?
  end

  def validate_gtag_type!
    ticket_type_id = params[:gtag][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: params[:gtag][:ticket_type_id])
    ticket_type && ticket_type.company_event_agreement == agreement &&
      ticket_type.event == current_event && ticket_type.deleted_at.nil?
  end
end
