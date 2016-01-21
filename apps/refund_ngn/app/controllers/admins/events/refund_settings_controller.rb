class Admins::Events::RefundSettingsController < Admins::Events::BaseController
  def index
    @event = Event.friendly.find(params[:event_id])
    @refund_parameters = @fetcher.event_parameters.where(
      parameters: {
        group: @event.selected_refund_services.map(&:to_s),
        category: "refund" }).includes(:parameter)
    @event_parameters = @fetcher.event_parameters.where(
      parameters: {
        group: "refund",
        category: "event" }).includes(:parameter)
  end

  def edit
    @event = Event.friendly.find(params[:event_id])
    @refund_service = params[:id]
    @parameters = Parameter.where(group: @refund_service, category: "refund")
    @refund_settings_form = ("#{@refund_service.camelize}RefundSettingsForm").constantize.new
    event_parameters = @fetcher.event_parameters.where(
      parameters: {
        group: @refund_service,
        category: "refund" }).includes(:parameter)
    event_parameters.each do |event_parameter|
      @refund_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @refund_service = params[:id]
    @parameters = Parameter.where(group: @refund_service, category: "refund")
    @refund_settings_form = ("#{@refund_service.camelize}RefundSettingsForm")
                            .constantize.new(permitted_params)
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

  private

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
      :bank_account_disclaimer)
  end
end
