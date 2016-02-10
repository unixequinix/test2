class AdminPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    admin_data = params.fetch("admin", {})
    !(admin_data["email"].blank? || admin_data["password"].blank?)
  end

  def authenticate!
    admin = Admin.find_by_email(params["admin"].fetch("email"))
    password_ok = !Authentication::Encryptor.compare(admin.encrypted_password,
                                                     params["admin"].fetch("password"))

    fail!(message: "errors.messages.unauthorized") && return if admin.nil? || password_ok
    admin.update_tracked_fields!(request)
    success!(admin)
  end
end
