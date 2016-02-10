class CustomerPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    customer_data = params.fetch("customer", {})
    !(customer_data["email"].blank? || customer_data["password"].blank?)
  end

  def authenticate!
    customer = Customer.find_by(email: params["customer"].fetch("email"),
                                event_id: params["customer"].fetch("event_id"))
    password_not_ok = !Authentication::Encryptor.compare(customer.encrypted_password,
                                                         params["customer"].fetch("password"))

    fail!(message: "errors.messages.unauthorized") && return if customer.nil? || password_not_ok
    fail!(message: "errors.messages.unconfirmed") && return if customer.confirmed_at.nil?

    customer.update_tracked_fields!(request)
    success!(customer)
  end
end
