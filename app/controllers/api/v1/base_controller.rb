module Api::V1
  class BaseController < ActionController::API
    include ActionController::Serialization
    include ActionController::HttpAuthentication::Basic::ControllerMethods

    before_action :restrict_access_with_http

    serialization_scope :view_context

    private

    def restrict_access_with_http
      authenticate_or_request_with_http_basic do |email, token|
        user = User.find_by(email: email)
        user && user.access_token.eql?(token)
      end
    end
  end
end

