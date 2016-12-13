class Admins::Events::GtagSettingsController < Admins::Events::BaseController
  before_action :set_settings

  def update
    atts = {
      gtag_name: permitted_params[:gtag_name],
      gtag_form_disclaimer: permitted_params[:gtag_form_disclaimer],
      gtag_assignation_notification: permitted_params[:gtag_assignation_notification],
      gtag_settings: current_event.gtag_settings.merge(permitted_params[:gtag_settings])
    }
    if current_event.update(atts)
      redirect_to admins_event_gtag_settings_url(current_event), notice: I18n.t("alerts.updated")
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def set_settings
    @gtag_settings = current_event.gtag_settings.reject { |key| Gtag::DEFINITIONS.keys.include?(key.to_sym) }
    @gtag_name = current_event.gtag_name
    @gtag_form_disclaimer = current_event.gtag_form_disclaimer
    @gtag_assignation_notification = current_event.gtag_assignation_notification
  end

  def permitted_params
    params.permit(:gtag_name, :gtag_form_disclaimer, :gtag_assignation_notification, gtag_settings: [Gtag::SETTINGS])
  end
end
