class ApplicationController < ActionController::Base
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery with: :exception

  protected

  def user_not_authorized
    flash[:error] = t("alerts.not_authorized")

    respond_to do |format|
      format.html { redirect_to admins_events_path }
      format.json { render json: { error: flash[:error] }, status: :unauthorized }
      format.text { "User not authorized" }
      format.js { render action: 'role_not_authorized' }
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation event_id]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
