class Companies::Api::V1::BaseController < Companies::BaseController
  before_action :restrict_access_with_http
  attr_reader :current_event, :current_company

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |company, token|
      @current_event = Event.find_by(token: token)
      @current_company = Company.find_by(name: company, event: @current_event)
      @current_event && @current_company
    end
  end
end
