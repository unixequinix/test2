class CustomerPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    customer_data = params.fetch("customer", {})
    !(customer_data["email"].blank? || customer_data["password"].blank?)
  end

  def authenticate!
    customer = Customer.find_by(email: params["customer"].fetch("email"),
                                event_id: params["customer"].fetch("event_id"))
    if customer.nil? || !Authentication::Encryptor.compare(customer.encrypted_password, params["customer"].fetch("password"))
      fail!(message: "errors.messages.unauthorized")
    elsif customer.confirmed_at.nil?
      fail!(message: "errors.messages.unconfirmed")
    else
      customer.update_tracked_fields!(request)
      success!(customer)
    end
  end
end
