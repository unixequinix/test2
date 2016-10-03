class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  before_action :set_device_settings, only: [:show, :edit]

  def edit
    @device_settings_form = DeviceSettingsForm.new

    @event_parameters.each do |event_parameter|
      @device_settings_form[event_parameter.parameter.name.to_sym] = event_parameter.value
    end
  end

  def update
    @device_settings_form = DeviceSettingsForm.new(permitted_params)

    if @device_settings_form.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_device_settings_url(current_event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def remove_db
    if params[:db] == "basic"
      current_event.update(device_basic_db: nil)
    else
      current_event.update(device_full_db: nil)
    end
    redirect_to admins_event_device_settings_url(current_event)
  end

  private

  def set_device_settings
    @event_parameters = current_event.event_parameters
                                     .where(parameters: { category: "device", group: "general" })
                                     .includes(:parameter)
  end

  def permitted_params
    params_names = Parameter.where(category: "device", group: "general").map(&:name)
    params_names << :event_id
    params.require("device_settings_form").permit(params_names)
  end
end
