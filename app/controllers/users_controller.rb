class UsersController < ApplicationController
  layout "welcome_admin"

  def show
    @user = current_user
    render layout: "admin"
  end

  def new
    @user = User.new(email: params[:email])
    @email_disabled = true if params[:email].present?
  end

  def create
    @user = User.new(permitted_params.merge(role: "promoter"))
    if @user.save
      EventRegistration.where(email: @user.email).update_all(user_id: @user.id)
      sign_in(@user, scope: :user)
      redirect_to admins_events_path, notice: t("alerts.created")
    else
      @email_disabled = true if params[:email_disabled]
      render :new
    end
  end

  def edit
    @user = current_user
    render layout: "admin"
  end

  def update
    @user = current_user
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

  def permitted_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
