class Events::PasswordsController < Events::BaseController
  layout 'event'
  skip_before_filter :authenticate_customer!

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.find_by(email: permitted_params[:email], event: current_event)
    if !@customer.nil?
      @customer.init_password_token!
      CustomerMailer.reset_password_instructions_email(@customer).deliver_later
      flash[:notice] = I18n.t("auth.passwords.send_instructions")
      redirect_to after_sending_reset_password_instructions_path
    else
      @customer = Customer.new
      flash.now[:error] = I18n.t('auth.failure.invalid', authentication_keys: 'email')
      render :new
    end
  end

  def edit
    @customer = Customer.find_by(reset_password_token: params[:reset_password_token])
    if !@customer.nil?
      @reset_password_form = ResetPasswordForm.new(@customer)
    else
      flash[:error] = I18n.t("errors.messages.expired")
      redirect_to customer_root_url(current_event)
    end
  end

  def update
    customer = Customer.find_by(reset_password_token: permitted_params[:reset_password_token])
    @reset_password_form = ResetPasswordForm.new(customer)
    if @reset_password_form.reset_password_sent_at < 2.hours.ago
      redirect_to edit_event_passwords_path(current_event), alert: I18n.t('errors.messages.expired')
    elsif @reset_password_form.validate(permitted_params) && @reset_password_form.save
      redirect_to customer_root_url(current_event), notice: I18n.t('auth.passwords.updated')
    else
      render :edit
    end
  end

  private

  def after_resetting_password_path
    new_event_session_path(current_event)
  end

  def after_sending_reset_password_instructions_path
    event_login_path(current_event, password_sent: true)
  end

  def permitted_params
    params.require(:customer)
      .permit(:event_id, :email, :password, :password_confirmation,
        :reset_password_token)
  end
end
