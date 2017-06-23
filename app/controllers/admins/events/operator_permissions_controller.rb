class Admins::Events::OperatorPermissionsController < Admins::Events::BaseController
  before_action :set_permission, except: %i[index new create]

  def index
    @permissions = @current_event.operator_permissions.page(params[:page])
    authorize @permissions
  end

  def new
    @permission = @current_event.operator_permissions.new(mode: "permanent")
    authorize @permission
  end

  def create
    @permission = @current_event.operator_permissions.new(permitted_params)
    authorize @permission

    if @permission.save
      flash[:notice] = t("alerts.created")
      redirect_to admins_event_operator_permissions_path
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @permission.update(permitted_params)
        flash[:notice] = t("alerts.updated")
        format.html { redirect_to admins_event_operator_permissions_path }
        format.json { render json: @permission }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: { errors: @permission.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @permission.destroy
        format.html { redirect_to admins_event_operator_permissions_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @permission], alert: @permission.errors.full_messages.to_sentence }
        format.json { render json: @permission.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_permission
    @permission = @current_event.operator_permissions.find(params[:id])
    authorize @permission
  end

  def permitted_params
    params.require(:operator_permission).permit(:role, :station_id, :group, :name)
  end
end
