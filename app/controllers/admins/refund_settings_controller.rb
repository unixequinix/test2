class Admins::RefundSettingsController < Admins::BaseController

  def show
    @event = current_event
    @event_parameters = EventParameter.where(event_id: @event.id, parameters: { group: @event.refund_service, category: 'refund'}).includes(:parameter)
  end

  def edit
    @event = current_event
    @parameters = Parameter.where(group: @event.refund_service, category: 'refund')
    @refund_settings_form = ("#{@event.refund_service.camelize}RefundSettingsForm").constantize.new
    event_parameters = EventParameter.where(event_id: @event.id, parameters: { group: @event.refund_service, category: 'refund'}).includes(:parameter)
    event_parameters.each do |event_parameter|
      @refund_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
    @refund_settings_form[:refund_success_message] = @event.refund_success_message
    @refund_settings_form[:mass_email_claim_notification] = @event.mass_email_claim_notification
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.refund_service, category: 'refund')
    @refund_settings_form = ("#{@event.refund_service.camelize}RefundSettingsForm").constantize.new(permitted_params)
    if @refund_settings_form.save
      @event.refund_success_message = permitted_params[:refund_success_message]
      @event.mass_email_claim_notification = permitted_params[:mass_email_claim_notification]
      @event.save
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_refund_settings_url(@event)
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  def notify_customers
    @event = Event.friendly.find(params[:event_id])
    if RefundNotificationService.new.notify(@event)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_refund_settings_url(@event)
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(group: current_event.refund_service, category: 'refund').map(&:name)
    params_names << :event_id
    params_names << :refund_success_message
    params_names << :mass_email_claim_notification
    params.require("#{current_event.refund_service}_refund_settings_form").permit(params_names)
  end

end
