class Admins::UsersController < Admins::BaseController
  before_action :set_user, only: %i[update destroy show]
  before_action :authorize!

  def index
    @users = User.all.order(:email).page(params[:per_page])
  end

  def update
    respond_to do |format|
      if @user.update(permitted_params)
        format.html { redirect_to admins_user_path(@user), notice: t("alerts.updated") }
        format.json { render status: :ok, json: @user }
      else
        format.html { render :edit }
        format.json { render json: { errors: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize!
    raise Pundit::NotAuthorizedError, "you are not authorized" unless current_user.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def permitted_params
    params.require(:user).permit(:role, :email, :username, :access_token)
  end
end
