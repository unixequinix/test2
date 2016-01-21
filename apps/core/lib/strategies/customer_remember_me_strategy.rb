class CustomerRememberMeStrategy < ::Warden::Strategies::Base
  def valid?
    request.cookies["remember_token"]
  end

  def authenticate!
    token = request.cookies["remember_token"]
    return unless token
    customer = Customer.find_by(remember_token: token)
    return unless customer
    success!(customer)
  end
end
