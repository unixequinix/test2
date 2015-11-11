class CustomerRememberMeStrategy < ::Warden::Strategies::Base

  def valid?
    request.cookies['remember_me_token']
  end

  def authenticate!
    if token = request.cookies['remember_me_token']
      if customer = Customer.first(remember_me_token: token)
        success!(customer)
      end
    end
  end
end
