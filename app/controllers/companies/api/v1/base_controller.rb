class Companies::Api::V1::BaseController < Companies::BaseController
  attr_reader :current_event
  before_action :restrict_access_with_http

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(id: event_token)
      @user = @current_event&.users&.find_by(access_token: company_token)
      @current_event && @user && @current_event.open_api? || render(status: :forbidden, json: :unauthorized)
    end
  end
end
