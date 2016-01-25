class Companies::Api::V1::BaseController < Companies::BaseController
  before_action :restrict_access_with_http

  def current_event
    @current_event
  end

  def current_company
    @current_company
  end

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |company, token|
      @current_event = Event.find_by(token: token)
      @current_company = Company.find_by(name: company, event: @current_event)
      @current_event && @current_company
    end
  end
end
