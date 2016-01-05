class CustomerRememberMeStrategy < ::Warden::Strategies::Base
  def valid?
    request.cookies["remember_token"]
  end

  def authenticate!
    if token = request.cookies["remember_token"]
      if customer = Customer.find_by(remember_token: token)
        success!(customer)
      end
    end
  end
end
