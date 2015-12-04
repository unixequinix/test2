class Events::SessionsController < Events::BaseController
  layout 'event'
  skip_before_filter :authenticate_customer!, only: [:new, :create]

  def new
    @sign_up = params[:sign_up]
    @confirmed = params[:confirmed]
    @password_sent = params[:password_sent]
    @confirmation_sent = params[:confirmation_sent]
    @customer_login_form = CustomerLoginForm.new(Customer.new)
    if customer_signed_in?
      redirect_to customer_root_path(current_event)
    end
  end

  def create
    customer = Customer.find_by(email: permitted_params[:email], event: current_event)
    if !customer.nil?
      @customer_login_form = CustomerLoginForm.new(customer)
      if @customer_login_form.validate(permitted_params) && @customer_login_form.save
        authenticate_customer!
        if params["customer"].fetch("remember_me") == "1"
          customer.init_remember_token!
          cookies['remember_token'] = { value: customer.remember_token, expires: Time.parse(customer.remember_me_token_expires_at(2.weeks).to_s) }
        end
        redirect_to after_sign_in_path
      else
        @customer_login_form = CustomerLoginForm.new(Customer.new)
        flash.now[:error] = I18n.t('auth.failure.invalid', authentication_keys: 'email')
        render :new
      end
    else
      @customer_login_form = CustomerLoginForm.new(Customer.new)
      flash.now[:error] = I18n.t('auth.failure.invalid', authentication_keys: 'email')
      render :new
    end
  end

  def destroy
    customer = current_customer
    logout_customer!
    redirect_to after_sign_out_path
  end

  private

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
