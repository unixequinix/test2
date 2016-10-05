class Admins::SessionsController < Admins::BaseController
  layout "welcome_admin"
  skip_before_action :authenticate_admin!, only: [:new, :create]

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.find_by(email: permitted_params[:email])
    if !@admin.nil? && authenticate_admin!
      redirect_to after_sign_in_path
    else
      @admin = Admin.new
      flash.now[:error] = I18n.t("auth.failure.invalid", authentication_keys: "email")
      render :new
    end
  end

  def destroy
    @admin = current_admin
    logout_admin!
    redirect_to after_sign_out_path
  end

  private

  def after_sign_out_path
    new_admins_sessions_path
  end

  def after_sign_in_path
    admin_root_path
  end

  def permitted_params
    params.require(:admin).permit(:email, :password, :remember_me)
  end
end
