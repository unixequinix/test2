class CustomerRememberMeStrategy < ::Warden::Strategies::Base

  def authenticate!
    if cookies[:remember_me_token]
      customer = Customer.authenticate_with_remember_me_token(cookies[:remember_me_token])
      customer && success!(customer)
    end
  end
end
