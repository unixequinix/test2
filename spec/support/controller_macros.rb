module ControllerMacros
  def login_customer
    login_as(:customer)
  end

  def login_admin
    login_as(:admin)
  end

  def http_login(user, access_token)
    request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic
                                        .encode_credentials(user, access_token)
  end
end
