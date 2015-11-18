class CustomerRememberMeStrategy < ::Warden::Strategies::Base

  def valid?
    request.cookies['remember_token']
  end

  def authenticate!
    if token = request.cookies['remember_token']
      if customer = Customer.find_by(remember_token: token, event_id: params["customer"].fetch("event_id"))
        success!(customer)
      end
    end
  end
end
