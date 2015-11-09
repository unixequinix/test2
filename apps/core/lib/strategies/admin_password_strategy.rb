class AdminPasswordStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    admin_data = params.fetch("admin", {})
    !(admin_data["email"].blank? || admin_data["password"].blank?)
  end

  def authenticate!
    admin = Admin.find_by_email(params["admin"].fetch("email"))
    current_password = BCrypt::Password.new(admin.encrypted_password)
    if admin.nil? ||
      current_password != params["admin"].fetch("password")
      fail! message: "errors.messages.unauthorized"
    else
      success!(admin)
    end
  end
end
