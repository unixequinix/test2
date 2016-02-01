class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  def show
    @event = current_event
    @event_parameters = @fetcher.event_parameters
                                .where(parameters: { category: "device" })
                                .includes(:parameter)
  end

  def edit
    @event = current_event
    @device_settings_form = DeviceSettingsForm.new
    event_parameters = @fetcher.event_parameters
                               .where(parameters: { category: "device" })
                               .includes(:parameter)

    event_parameters.each do |event_parameter|
      @device_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @event = Event.friendly.find(params[:event_id])
    @parameters = Parameter.where(group: "form", category: "gtag")
    @device_settings_form = DeviceSettingsForm.new(permitted_params)

    if @device_settings_form.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_device_settings_url(@event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  private

  def permitted_params
    params_names = Parameter.where(category: "device").map(&:name)
    params_names << :event_id
    params.require("device_settings_form").permit(params_names)
  end
end
