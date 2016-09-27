class Admins::Events::RefundSettingsController < Admins::Events::BaseController
  def index
    @event = Event.friendly.find(params[:event_id])
    @refund_parameters = @fetcher.event_parameters.where(
      parameters: {
        group: @event.selected_refund_services.map(&:to_s),
        category: "refund"
      }
    ).includes(:parameter)
    @event_parameters = @fetcher.event_parameters.where(parameters: { group: "refund", category: "event" })
                                                 .includes(:parameter)
    @direct_claim_profiles = direct_claim_profiles.count
  end

  def edit
    @event = Event.friendly.find(params[:event_id])
    @refund_service = params[:id]
    @parameters = Parameter.where(group: @refund_service, category: "refund")
    @refund_settings_form = "#{@refund_service.camelize}RefundSettingsForm".constantize.new
    event_parameters = @fetcher.event_parameters.where(parameters: { group: @refund_service, category: "refund" })
                                                .includes(:parameter)
    event_parameters.each do |event_parameter|
      @refund_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @refund_service = params[:id]
    @parameters = Parameter.where(group: @refund_service, category: "refund")
    @refund_settings_form = "#{@refund_service.camelize}RefundSettingsForm".constantize.new(permitted_params)
    if @refund_settings_form.save
      @event.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_refund_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def edit_messages
    @event = Event.friendly.find(params[:event_id])
  end

  def update_messages
    @event = Event.friendly.find(params[:event_id])
    if @event.update(permitted_event_params)
      flash[:notice] = I18n.t("alerts.updated")
      @event.slug = nil
      @event.save!
      redirect_to admins_event_refund_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def notify_customers
    @event = Event.friendly.find(params[:event_id])
    if RefundNotification.new.notify(@event)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_refund_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def paypal_refund
    profiles = direct_claim_profiles.map do |profile|
      gtag = profile.active_gtag_assignment&.credentiable
      next unless gtag
      claim = Claim.new(service_type: Claim::DIRECT,
                        fee: current_event.refund_fee(Claim::DIRECT),
                        minimum: current_event.refund_minimun(Claim::DIRECT),
                        profile: profile,
                        gtag: gtag,
                        total: profile.refundable_money,
                        aasm_state: "in_progress")
      claim.generate_claim_number!
      claim.save!
      claim.start_claim!

      if Management::RefundManager.new(profile, profile.refundable_money).execute
        RefundService.new(claim).create(amount: profile.refundable_money_after_fee(Claim::DIRECT),
                                        currency: current_event.currency,
                                        message: "Created direct refund",
                                        payment_solution: Claim::DIRECT,
                                        status: "SUCCESS")
      end
    end

    if profiles.all?
      flash[:notice] = I18n.t("alerts.updated")
    else
      flash[:alert] = I18n.t("alerts.error")
    end
    redirect_to admins_event_refund_settings_url(current_event)
  end

  private

  def direct_claim_profiles
    claim_ids = Claim.completed.where(profile_id: current_event.profiles.pluck(:id)).pluck(:profile_id)

    profiles = current_event.profiles
    profiles = profiles.where("id NOT IN (?)", claim_ids) if claim_ids.present?

    profiles.where("refundable_credits > 0").select(&:valid_balance?).select(&:enough_money?)
  end

  def permitted_params
    params_names = Parameter.where(group: @refund_service, category: "refund").map(&:name)
    params_names << :event_id
    params.require("#{@refund_service}_refund_settings_form").permit(params_names)
  end

  def permitted_event_params
    params.require(:event).permit(
      :refund_success_message,
      :mass_email_claim_notification,
      :refund_disclaimer,
      :bank_account_disclaimer
    )
  end
end
