class CustomerPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    customer_data = params.fetch("customer", {})
    !(customer_data["email"].blank? || customer_data["password"].blank?)
  end

  def authenticate!
    customer = Customer.find_by_email(params["customer"].fetch("email"), )
    if customer.nil? || customer.confirmed_at.nil? || customer.password != params["customer"].fetch("password")
      fail! message: "errors.messages.unauthorized"
    else
      success!(customer)
    end
  end
end
