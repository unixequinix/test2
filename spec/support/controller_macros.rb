module ControllerMacros
  def http_login(event_token, company_token)
    request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(event_token, company_token)
  end

  def token_login(user, event, role = "promoter")
    event.event_registrations.create!(email: user.email, role: role, user: user)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.access_token)
  end
end
