module ControllerMacros
  def http_login(event_token, company_token)
    request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(event_token, company_token)
  end
end
