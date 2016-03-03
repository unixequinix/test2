module ControllerMacros
  def http_login(admin_email, admin_token)
    request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic
                                        .encode_credentials(admin_email, admin_token)
  end
end
