class ApplicationController < ActionController::Base
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  attr_reader :current_event

  protected

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation event_id]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  private

  def user_not_authorized
    return_url = admins_events_path
    respond_to do |format|
      format.html { redirect_to return_url, alert: t("alerts.not_authorized") }
      format.json { render json: { error: t("alerts.not_authorized") }, status: :unauthorized }
      format.text { "User not authorized" }
    end
  end

  def fetch_current_event
    params[:event_id] ||= params[:id]
    @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
  end

  def restrict_app_version
    head(:upgrade_required, app_version: @current_event.app_version) unless @current_event.valid_app_version?(params[:app_version])
  end

  def restrict_access_with_http
    skip_authorization
    skip_policy_scope
    authenticate_or_request_with_http_basic do |email, token|
      user = User.find_by(email: email)
      user && user.access_token.eql?(token)
    end
  end
end
