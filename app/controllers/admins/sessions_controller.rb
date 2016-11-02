class Admins::SessionsController < Devise::SessionsController
  layout "welcome_admin"

  private

  def after_sign_out_path_for(_resource)
    new_admin_session_path
  end
end
