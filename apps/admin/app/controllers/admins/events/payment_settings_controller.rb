class Admins::Events::PaymentSettingsController < Admins::Events::BaseController

  def show
    @event = Event.friendly.find(params[:event_id])
    @event_parameters = EventParameter.where(event_id: @event.id, parameters: { group: @event.payment_service, category: 'payment'}).includes(:parameter)
  end

  def edit
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.payment_service, category: 'payment')
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm").constantize.new
    event_parameters = EventParameter.where(event_id: @event.id, parameters: { group: @event.payment_service, category: 'payment'}).includes(:parameter)
    event_parameters.each do |event_parameter|
      @payment_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: @event.payment_service, category: 'payment')
    @payment_settings_form = ("#{@event.payment_service.camelize}PaymentSettingsForm").constantize.new(permitted_params)
    if @payment_settings_form.save
      @event.save
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_payment_settings_url(@event)
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(group: current_event.payment_service, category: 'payment').map(&:name)
    params_names << :event_id
    params.require("#{current_event.payment_service}_payment_settings_form").permit(params_names)
  end

end
