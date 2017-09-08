module Api::V2
  class BaseController < ActionController::API
    include Pundit
    include ActionController::Serialization
    include ActionController::HttpAuthentication::Token::ControllerMethods

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized

    before_action :authenticate     # Authenticate all requests.
    before_action :destroy_session  # APIs are stateless
    before_action :verify_event

    after_action :verify_authorized # disable not to raise exception when action does not have authorize method

    protected

    def authenticate
      authenticate_with_http_token { |token, _| @current_user = User.find_by(access_token: token) } || render_unauthorized
    end

    def render_unauthorized(realm = "Application")
      headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}") if realm.is_a?(String)
      render json: { error: 'Forbidden access' }, status: :forbidden
    end

    def destroy_session
      request.session_options[:skip] = true
    end

    def verify_event
      @current_event = Event.friendly.find(params[:event_id] || params[:id])
      render json: { error: "Event '#{params[:event_id]}' not found" }, status: :bad_request unless @current_event
      render json: { error: "Event '#{@current_event.name}' does not have the API open" }, status: :unauthorized unless @current_event.open_api?
    end
  end
end
