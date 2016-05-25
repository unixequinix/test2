class CustomerRememberMeStrategy < ::Warden::Strategies::Base
  def valid?
    request.cookies["remember_token"]
  end

  def authenticate!
    token = request.cookies["remember_token"]

    return if params.blank?

    customer = Customer.find_by(remember_token: token, event_id: params["customer"]["id"])
    fail!(message: "errors.messages.unauthorized") && return if customer.nil?
    success!(customer)
  end
end
