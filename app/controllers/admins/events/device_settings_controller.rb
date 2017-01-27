class Admins::Events::DeviceSettingsController < Admins::Events::BaseController
  before_action :execute_policy

  def update
    if @current_event.update(permitted_params)
      redirect_to admins_event_device_settings_path(@current_event), notice: I18n.t("alerts.updated")
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def remove_db
    @current_event.update(params[:db] => nil)
    redirect_to admins_event_device_settings_path(@current_event)
  end

  def load_defaults
    params[:event] = Event.new.attributes
    @current_event.update!(permitted_params)
    redirect_to admins_event_device_settings_path(@current_event), notice: I18n.t("alerts.updated")
  end

  private

  def execute_policy
    authorize @current_event, :event_settings?
  end

  def permitted_params
    params.require(:event).permit(:private_zone_password,
                                  :fast_removal_password,
                                  :touchpoint_update_online_orders,
                                  :pos_update_online_orders,
                                  :topup_initialize_gtag,
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
