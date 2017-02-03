class Admins::Events::GtagSettingsController < Admins::Events::BaseController
  before_action :execute_policy

  def update
    if @current_event.update(permitted_params)
      redirect_to admins_event_gtag_settings_path(@current_event), notice: t("alerts.updated")
    else
      flash[:error] = t("alerts.error")
      render :edit
    end
  end

  def load_defaults
    params[:event] = Event.new.attributes
    atts = { gtag_form_disclaimer: nil, gtag_assignation_notification: nil }.merge(permitted_params)
    @current_event.update!(atts)
    redirect_to admins_event_gtag_settings_path(@current_event), notice: t("alerts.updated")
  end

  private

  def execute_policy
    authorize @current_event, :event_settings?
  end

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.require(:event).permit(:gtag_form_disclaimer,
                                  :gtag_assignation_notification,
                                  :format,
                                  :gtag_type,
                                  :gtag_deposit,
                                  :initial_topup_fee,
                                  :topup_fee,
                                  :ultralight_c,
                                  :mifare_classic,
                                  :ultralight_ev1,
                                  :cards_can_refund,
                                  :maximum_gtag_balance,
                                  :wristbands_can_refund,
                                  :gtag_deposit_fee,
                                  :topup_fee,
                                  :card_return_fee)
  end
end
