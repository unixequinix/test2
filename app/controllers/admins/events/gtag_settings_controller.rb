class Admins::Events::GtagSettingsController < Admins::Events::BaseController
  def update
    type_cast_booleans(%w( cards_can_refund wristbands_can_refund ))

    if @current_event.update(permitted_params)
      redirect_to admins_event_gtag_settings_path(@current_event), notice: I18n.t("alerts.updated")
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def load_defaults
    defaults = YAML.load(ERB.new(File.read("#{Rails.root}/config/glownet/gtag_settings.yml")).result)
    @current_event.update!(gtag_settings: defaults,
                           gtag_name: "wristband",
                           gtag_form_disclaimer: nil,
                           gtag_assignation_notification: nil)
    redirect_to admins_event_gtag_settings_path(@current_event), notice: I18n.t("alerts.updated")
  end

  private

  def permitted_params
    params.require(:event).permit(:gtag_name,
                                  :gtag_form_disclaimer,
                                  :gtag_assignation_notification,
                                  :format,
                                  :gtag_type,
                                  :gtag_deposit,
                                  :ultralight_c,
                                  :mifare_classic,
                                  :ultralight_ev1,
                                  :cards_can_refund,
                                  :maximum_gtag_balance,
                                  :wristbands_can_refund)
  end
end
