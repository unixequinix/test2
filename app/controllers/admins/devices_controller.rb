class Admins::DevicesController < Admins::BaseController
  before_action :set_devices, only: [:index, :search]
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  def index
    @devices = Device.all.page(params[:page])
  end

  def search
    @devices = Device.all.page(params[:page])
  end

  def show
    @device_events = DeviceTransaction.where(device_uid: @device.mac).includes(:event).group_by(&:event)
  end

  def update
    respond_to do |format|
      if @device.update(permitted_params)
        format.json { render json: @device }
        format.html { redirect_to [:admins, @device] }
      else
        format.json { render status: :unprocessable_entity, json: :no_content }
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @device.destroy
      flash[:notice] = t("alerts.destroyed")
    else
      flash[:error] = @ticket.errors.full_messages.join(". ")
    end
    redirect_to admins_devices_path
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  def set_devices
    @devices = params[:filter].nil? ? Device.all : Device.where("substr(asset_tracker, 1, 1) = ?", params[:filter])
  end

  def permitted_params
    params.require(:device).permit(:device_model, :asset_tracker)
  end
end
