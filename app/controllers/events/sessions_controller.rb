class Events::SessionsController < Events::DeviseBaseController
  skip_before_action :authenticate_customer!

  def new
    @sign_up = params[:sign_up]
    @confirmed = params[:confirmed]
    @password_sent = params[:password_sent]
    @customer = Customer.new
  end

  def create
    @customer = Customer.find_by(email: permitted_params[:email])
    if !@customer.nil? && @customer.valid_password?(permitted_params[:password])
      sign_in(@customer)
      create_customer_event_profile(@customer)
      redirect_to after_sign_in_path_for(@customer)
    else
      @customer = Customer.new
      flash.now[:error] = I18n.t('devise.failure.invalid', authentication_keys: 'email')
      render :new
    end
  end

  def destroy
    customer = current_customer
    sign_out(customer)
    redirect_to after_sign_out_path_for(customer)
  end

  private

  def permitted_params
    params.require(:customer)
      .permit(:email, :password, :remember_me)
  end

  def after_sign_out_path_for(resource)
    return event_url(current_event)
  end

  def after_sign_in_path_for(resource)
    sign_in_url = new_event_session_path(current_event)
    if request.referer == sign_in_url
      super
    else
      event_url(current_event) || request.referer || customer_root_path
    end
  end

end
