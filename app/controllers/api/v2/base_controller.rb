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
      render json: { error: 'Bad credentials' }, status: :unauthorized
    end

    def destroy_session
      request.session_options[:skip] = true
    end

    def verify_event
      @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
      render json: { error: 'Event not found' }, status: :bad_request unless @current_event
    end
  end
end
