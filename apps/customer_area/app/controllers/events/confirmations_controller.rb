class Events::ConfirmationsController < Events::BaseController
  layout "welcome_customer"
  skip_before_filter :authenticate_customer!

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.find_by(email: permitted_params[:email], event: current_event)

    event_login_path(current_event, confirmed: true) && return if @customer.present?
    redirect_to event_login_path(current_event, confirmed: true),
                error: I18n.t("errors.messages.already_confirmed") &&
                  return unless @customer.confirmed_at.present?

    CustomerMailer.confirmation_instructions_email(@customer).deliver_later
    @customer.update(confirmation_sent_at: Time.now.utc)
    redirect_to after_sending_confirmation_instructions_path,
                notice: t("auth.confirmations.send_instructions")
  end

  def show
    @customer = Customer.where(confirmation_token: params[:confirmation_token]).first
    if @customer.nil?
      flash.alert = t("errors.messages.not_found")
      redirect_to event_url(current_event)
    else
      flash.notice = t("auth.confirmations.confirmed")
      @customer.confirm!
      warden.set_user(@customer, scope: :admin)
      redirect_to after_confirmation_path
    end
  end

  private

  def redirect_if_token_empty!
    return if params.key?(:token)
    flash.alert = t("confirmations.token.empty")
    redirect_to(:root) && return
  end

  def after_sending_confirmation_instructions_path
    event_login_path(current_event, confirmation_sent: true)
  end

  def after_confirmation_path
    event_login_path(current_event, confirmed: true)
  end

  def permitted_params
    params.require(:customer)
      .permit(:email, :password, :password_confirmation, :confirmation_token)
      .merge(event_id: current_event.id)
  end
end
