class Admins::Events::GtagSettingsController < Admins::Events::BaseController
  def update
    atts = type_cast_booleans(%w( cards_can_refund wristbands_can_refund ), permitted_params)
    if @current_event.update(atts)
      redirect_to admins_event_gtag_settings_path(@current_event), notice: I18n.t("alerts.updated")
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def load_defaults
    params[:event] = Event.new.attributes
    atts = { gtag_name: "wristband", gtag_form_disclaimer: nil, gtag_assignation_notification: nil }.merge(permitted_params)
    @current_event.update!(atts)
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
