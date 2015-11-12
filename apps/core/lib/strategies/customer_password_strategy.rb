class CustomerPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    customer_data = params.fetch("customer", {})
    !(customer_data["email"].blank? || customer_data["password"].blank?)
  end

  def authenticate!
    customer = Customer.find_by(email: params["customer"].fetch("email"),
      event_id: params["customer"].fetch("event_id"))
    if customer.nil? ||
      customer.confirmed_at.nil? ||
      BCrypt::Password.new(customer.encrypted_password) != params["customer"].fetch("password")
      fail! message: "errors.messages.unauthorized"
    else
      customer.update_tracked_fields!(request)
      success!(customer)
    end
  end
end
