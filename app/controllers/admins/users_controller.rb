class Admins::UsersController < ApplicationController
  layout "admin"

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_user, only: %i[update destroy show edit]

  def index
    @q = policy_scope(User).ransack(params[:q])
    @users = @q.result
    @users = User.all.order(:role, :email).page(params[:per_page]) if params[:q].blank?
    @users = @users.page(params[:page])
    authorize @users
  end

  def show; end

  def new
    @user = User.new(email: params[:email])
    @email_disabled = true if params[:email].present?
    render :new, layout: "welcome_admin"
  end

  def create
    @user = User.new(permitted_params.merge(role: "promoter"))
    if verify_recaptcha(model: @user) && @user.save
      EventRegistration.where(email: @user.email).update_all(user_id: @user.id)
      UserTeam.where(email: @user.email).update_all(user_id: @user.id)
      sign_in(@user, scope: :user)
      redirect_to admins_events_path, notice: t("alerts.created")
    else
      @email_disabled = true if params[:email_disabled]
      render :new, layout: "welcome_admin"
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @user.update(permitted_params)
        format.html { redirect_to admins_user_path(@user), notice: t("alerts.updated") }
        format.json { render status: :ok, json: @user }
      else
        format.html { render :show }
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

  def set_user
    @user = User.find(params[:user_id] || params[:id])
    authorize @user
  end

  def permitted_params
    params.require(:user).permit(:role, :email, :username, :access_token, :password, :password_confirmation)
  end
end
