module ControllerMacros
  def login_customer
    login_as(:customer)
  end

  def login_user
    login_as(:user)
  end

  def http_login(event_token, company_token)
    request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(event_token, company_token)
  end
end
