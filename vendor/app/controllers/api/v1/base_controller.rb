module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::Serialization
      include ActionController::HttpAuthentication::Basic::ControllerMethods

      before_action :restrict_access_with_http
      before_action :decrypt_app_id
      before_action :set_device

      serialization_scope :view_context

      private

      def decrypt_app_id
        @app_id = Base64.decode64(request.headers["HTTP_DEVICE_TOKEN"].to_s).split("+++").first
      end

      def set_device
        return true if @current_user.glowball?

        @device = Device.find_by(app_id: @app_id)
        render(status: :unauthorized, json: { error: "Device not registered" }) if @device.blank?
      end

      def restrict_access_with_http
        authenticate_or_request_with_http_basic do |email, token|
          @current_user = User.find_by(email: email.strip)
          @current_user&.access_token.eql?(token.strip)
        end
      end
    end
  end
end
