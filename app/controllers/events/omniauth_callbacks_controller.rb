class Events::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @customer = Customer.from_omniauth(request.env["omniauth.auth"], current_event)

    if @customer.persisted?
      bypass_sign_in @customer
      redirect_to customer_root_path(current_event)
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["omniauth"] = request.env["omniauth.auth"].except("extra")
      redirect_to event_register_path(current_event)
    end
  end

  def google_oauth2
    @customer = Customer.from_omniauth(request.env["omniauth.auth"], current_event)

    if @customer.persisted?
      bypass_sign_in @customer
      redirect_to customer_root_path(current_event)
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["omniauth"] = request.env["omniauth.auth"].except("extra")
      redirect_to event_register_path(current_event)
    end
  end

  def failure
    redirect_to customer_root_path(current_event)
  end

  def current_event
    @current_event = Event.find_by(slug: request.env["omniauth.params"]["event"])
  end
end
