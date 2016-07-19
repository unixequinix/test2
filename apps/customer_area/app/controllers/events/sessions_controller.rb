class Events::SessionsController < Events::BaseController
  layout "welcome_customer"
  skip_before_filter :authenticate_customer!, only: [:new, :create]
  before_action :check_authorization_flag!

  def new
    @sign_up = params[:sign_up]
    @password_sent = params[:password_sent]
    @customer_login_form = CustomerLoginForm.new(Customer.new)
    redirect_to customer_root_path(current_event) if customer_signed_in?
  end

  def create # rubocop:disable Metrics/AbcSize
    c_params = { email: permitted_params[:email].downcase, event: current_event }
    customer = Customer.find_by(c_params) || Customer.new
    @customer_login_form = CustomerLoginForm.new(customer)

    unless @customer_login_form.validate(permitted_params) && @customer_login_form.save
      flash.now[:error] = I18n.t("auth.failure.invalid", authentication_keys: "email")
      render(:new) && return
    end

    check_remember_token(params, customer)
    authenticate_customer!
    current_customer.update(locale: I18n.locale) if current_customer
    redirect_to after_sign_in_path
  end

  def destroy
    @customer = current_customer
    logout_customer!
    redirect_to after_sign_out_path
  end

  private

  def check_remember_token(params, customer)
    return false unless params["customer"].fetch("remember_me") == "1"
    customer.init_remember_token!
    token_expiration = customer.remember_me_token_expires_at(2.weeks).to_s
    cookies["remember_token"] = { value: customer.remember_token,
                                  expires: Time.zone.parse(token_expiration) }
  end

  def after_sign_out_path
    event_login_path(current_event)
  end

  def after_sign_in_path
    event_path(current_event)
  end

  def permitted_params
    params.require(:customer).permit(:email, :password, :event_id, :remember_me)
  end
end
