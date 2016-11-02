class Admins::AdminsController < Admins::BaseController
  before_action :set_admin, only: [:edit, :update, :destroy]

  def index
    @admins = Admin.all.page(params[:page])
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(permitted_params)
    if @admin.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_admins_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @admin.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_admins_url
    else
      render :edit
    end
  end

  def destroy
    if @admin.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @admin.errors.full_messages.join(". ")
    end
    redirect_to admins_admins_url
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def permitted_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end
