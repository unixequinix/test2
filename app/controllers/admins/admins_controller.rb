class Admins::AdminsController < Admins::BaseController
  def index
    @admins = Admin.all.page(params[:page])
  end

  def new
    @admin_form = NewAdminForm.new(Admin.new)
  end

  def create
    @admin_form = NewAdminForm.new(Admin.new)
    if @admin_form.validate(permitted_params) && @admin_form.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_admins_url
    else
      render :new
    end
  end

  def edit
    @admin_form = EditAdminForm.new(Admin.find(params[:id]))
  end

  def update
    @admin_form = EditAdminForm.new(Admin.find(params[:id]))
    if @admin_form.validate(permitted_params) && @admin_form.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_admins_url
    else
      render :edit
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    if @admin.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @admin.errors.full_messages.join(". ")
    end
    redirect_to admins_admins_url
  end

  private

  def permitted_params
    params.require(:admin).permit(:email, :current_password, :password)
  end
end
