class CustomerPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    !(c_attr("email").blank? || c_attr("password").blank?)
  end

  def authenticate!
    customer = Customer.find_by(email: c_attr("email"), event_id: c_attr("event_id"))
    bad_pass = !Authentication::Encryptor.compare(customer.encrypted_password, c_attr("password"))

    fail!(message: "errors.messages.unauthorized") && return if customer.nil? || bad_pass

    customer.update_tracked_fields!(request)
    success!(customer)
  end

  private

  def c_attr(attr_name)
    params.fetch("customer", {})[attr_name]
  end
end
