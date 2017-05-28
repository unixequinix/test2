class Admins::Events::EventRegistrationsController < Admins::Events::BaseController
  before_action :set_registration, except: %i[new create index]

  def index
    @registrations = EventRegistration.where(event: @current_event).includes(:user).order(%i[role]).page(params[:page])
    @registration = @current_event.event_registrations.new
    authorize @registrations
  end

  def create
    email = permitted_params[:email]
    @user = User.find_by(email: email)
    @registration = @current_event.event_registrations.new(permitted_params.merge(user: @user))
    authorize(@registration)

    if @registration.save
      if @user
        redirect_to admins_event_event_registrations_path, notice: t("alerts.created")
      else
        UserMailer.invite_to_event(@registration).deliver_now
        redirect_to admins_event_event_registrations_path, notice: "Invitation sent to '#{email}', when accepted, it will be added to your users"
      end
    else
      @registrations = EventRegistration.where(event: @current_event).order(%i[role]).page(params[:page])
      render :index
    end
  end

  def update
    respond_to do |format|
      if @registration.update(permitted_params)
        format.html { redirect_to admins_event_event_registrations_path, notice: t("alerts.updated") }
        format.json { render json: @registration }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: { errors: @registration.errors }, status: :unprocessable_entity }
      end
    end
  end

  def resend
    UserMailer.invite_to_event(@registration).deliver_now
    redirect_to admins_event_event_registrations_path, notice: "Invitation sent to '#{@registration.email}'"
  end

  def destroy
    respond_to do |format|
      if @registration.destroy
        format.html { redirect_to request.referer, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @registration], alert: @registration.errors.full_messages.to_sentence }
        format.json { render json: { errors: @registration.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_registration
    @registration = @current_event.event_registrations.find(params[:id])
    authorize @registration
  end

  def permitted_params
    params.require(:event_registration).permit(:email, :role)
  end
end
