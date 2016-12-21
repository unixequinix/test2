class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  def update
    cols = %w(uid_reverse touchpoint_update_online_orders pos_update_online_orders topup_initialize_gtag cypher_enabled)
    atts = type_cast_booleans(cols, permitted_params)

    if @current_event.update(atts)
      redirect_to admins_event_device_settings_path(@current_event), notice: I18n.t("alerts.updated")
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def remove_db
    @current_event.update(params[:db] => nil)
    redirect_to admins_event_device_settings_url(@current_event)
  end

  def load_defaults
    defaults = YAML.load(ERB.new(File.read("#{Rails.root}/config/glownet/device_settings.yml")).result)
    @current_event.update!(device_settings: defaults)
    redirect_to admins_event_device_settings_path(@current_event), notice: I18n.t("alerts.updated")
  end

  private

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.require(:event).permit(:min_version_apk,
                                  :private_zone_password,
                                  :fast_removal_password,
                                  :touchpoint_update_online_orders,
                                  :pos_update_online_orders,
                                  :topup_initialize_gtag,
                                  :cypher_enabled,
                                  :gtag_blacklist,
                                  :transaction_buffer,
                                  :days_to_keep_backup,
                                  :sync_time_event_parameters,
                                  :sync_time_server_date,
                                  :sync_time_basic_download,
                                  :sync_time_tickets,
                                  :sync_time_gtags,
                                  :sync_time_customers)
  end
end
