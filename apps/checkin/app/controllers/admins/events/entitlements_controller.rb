class Admins::Events::EntitlementsController < Admins::Events::CheckinBaseController

  def index
    @entitlements = Entitlement.where(event_id: current_event.id).page(params[:page])
  end

  def new
    @entitlement = Entitlement.new
  end

  def create
    @entitlement = Entitlement.new(permitted_params)
    if @entitlement.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_event_entitlements_url
    else
      flash[:error] = I18n.t('alerts.error')
      render :new
    end
  end

  def edit
    @entitlement = Entitlement.find(params[:id])
  end

  def update
    @entitlement = Entitlement.find(params[:id])
    if @entitlement.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_entitlements_url
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  def destroy
    @entitlement = Entitlement.find(params[:id])
    if @entitlement.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_event_entitlements_url
    else
      flash[:error] = @entitlement.errors.full_messages.join(". ")
      redirect_to admins_event_entitlements_url
    end
  end

  private

  def permitted_params
    params.require(:entitlement).permit(:event_id, :name)
  end

end
