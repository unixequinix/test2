class Admins::DevicesController < Admins::BaseController
  before_action :set_device, only: %i[show edit update destroy]
  before_action :authorize!

  def index
    @q = Device.ransack(params[:q])
    @devices = @q.result.includes(:events)
    @devices = @devices.page(params[:page])
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

  def authorize!
    raise Pundit::NotAuthorizedError, "you are not authorized" unless current_user.admin?
  end

  def set_device
    @device = Device.find(params[:id])
  end

  def permitted_params
    params.require(:device).permit(:mac, :asset_tracker)
  end
end
