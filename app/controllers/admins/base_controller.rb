class Admins::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :verify_authorized # disable not to raise exception when action does not have authorize method

  private

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to admins_events_path, alert: t("alerts.not_authorized") }
      format.json { render json: { error: t("alerts.not_authorized") }, status: :unauthorized }
      format.text { "User not authorized" }
    end
  end
end
