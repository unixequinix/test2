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
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to admins_event_users_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @user], alert: @user.errors.full_messages.to_sentence }
        format.json { render json: { errors: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = @current_event.users.find(params[:id])
    authorize @user
  end

  def permitted_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
