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
end
