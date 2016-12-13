class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  before_action :set_settings, except: :remove_db

  def update
    atts = @device_settings.merge(permitted_params[:device_settings])
    if current_event.update(device_settings: atts)
      redirect_to admins_event_device_settings_url(current_event), notice: I18n.t("alerts.updated")
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

  def set_settings
    @device_settings = current_event.device_settings
  end

  def permitted_params
    params.permit(device_settings: Device::SETTINGS)
  end
end
