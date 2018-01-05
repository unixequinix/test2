class Admins::Users::Teams::DevicesController < Admins::BaseController
  before_action :set_device, only: %i[show edit update destroy]

  def index
    @q = Device.ransack(params[:q])
    @devices = @q.result.includes(:events)
    authorize(@devices)
    @devices = @devices.page(params[:page])
  end

  def show
    @device_events = DeviceTransaction.where(device_uid: @device.mac).includes(:event).group_by(&:event)
  end

  def edit; end

  def update
    respond_to do |format|
      if @device.update(permitted_params)
        format.json { render json: @device }
        format.html { redirect_to [:admins, current_user, :team, @device] }
      else
        format.json { render status: :unprocessable_entity, json: :no_content }
        format.html { render :edit }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @device.destroy
        format.html { redirect_to admins_user_team_devices_path(current_user), notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, current_user, :team, @device], alert: @device.errors.full_messages.to_sentence }
        format.json { render json: { errors: @device.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_device
    @device = Device.find(params[:id])
    authorize(@device)
  end

  def permitted_params
    params.require(:device).permit(:mac, :asset_tracker)
  end
end
