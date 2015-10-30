class Admins::AdminsController < Admins::BaseController

  def index
    @admins = Admin.all.page(params[:page])
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(permitted_params)
    if @admin.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_admins_url
    else
      flash[:error] = @admin.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @admin = Admin.find(params[:id])
  end

  def update
    @admin = Admin.find(params[:id])
    if @admin.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_admins_url
    else
      flash[:error] = @admin.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    if @admin.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_admins_url
    else
      flash[:error] = @admin.errors.full_messages.join(". ")
      redirect_to admins_admins_url
    end
  end

  private

  def permitted_params
    params.require(:admin).permit(:email, :password)
  end
end
