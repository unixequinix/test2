class Admins::UsersController < Admins::BaseController
  before_action :set_user, only: %i[update destroy show destroy]
  before_action :authorize!

  def index
    @q = policy_scope(User).ransack(params[:q])
    @users = @q.result
    @users = User.all.order(:role, :email).page(params[:per_page]) if params[:q].blank?
    @users = @users.page(params[:page])
    render layout: "admin"
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

  def destroy
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to admins_users_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to @user, alert: @user.errors.full_messages.to_sentence }
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
    authorize @user
  end

  def permitted_params
    params.require(:user).permit(:role, :email, :username, :access_token)
  end
end
