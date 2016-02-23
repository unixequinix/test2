class Companies::Api::V1::BaseController < Companies::BaseController
  before_action :restrict_access_with_http
  attr_reader :current_event, :current_company

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)
      @current_company = Event.company_event_agreement
                        .companies
                        .find_by(companies: { token: company_token })
      @current_event && @current_company
    end
  end
end
