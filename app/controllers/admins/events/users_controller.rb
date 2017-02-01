class Admins::Events::UsersController < Admins::Events::BaseController
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = @current_event.users.order([:role, :email]).page(params[:page])
    authorize @users
  end

  def new
    @user = @current_event.users.new
    authorize @user
  end

  def create
    @user = @current_event.users.new(permitted_params)
    authorize @user
    if @user.save
      redirect_to admins_event_users_path, notice: t("alerts.created")
    else
      render :new
    end
  end

  def update
    if @user.update(permitted_params)
      redirect_to admins_event_users_path, notice: t("alerts.updated")
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      redirect_to admins_event_users_path, notice: t("alerts.destroyed")
    else
      redirect_to [:admins, @current_event, @user], error: t("alerts.error")
    end
  end

  private

  def set_user
    @user = @current_event.users.find(params[:id])
    authorize @user
  end

  def permitted_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
