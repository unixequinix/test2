class UsersController < ApplicationController
  layout "welcome_admin"

  def new
    @user = User.new
  end

  def create
    @user = User.new(permitted_params.merge(role: "promoter"))
    if @user.save
      sign_in(@user, scope: :user)
      redirect_to admins_events_path, notice: t("alerts.created")
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(permitted_params)
      redirect_to admins_events_path, notice: t("alerts.updated")
    else
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
