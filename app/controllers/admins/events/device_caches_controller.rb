class Admins::Events::DeviceCachesController < Admins::Events::BaseController
  before_action :set_device_cache, only: %i[destroy]

  def destroy
    @device_cache.file.destroy
    @device_cache.file.clear

    respond_to do |format|
      if @device_cache.destroy
        format.html { redirect_to device_settings_admins_event_path(@current_event), notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to device_settings_admins_event_path(@current_event), alert: @device_cache.errors.full_messages.to_sentence }
        format.json { render json: { errors: @device_cache.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_device_cache
    @device_cache = @current_event.device_caches.find(params[:id])
    authorize @device_cache
  end
end
