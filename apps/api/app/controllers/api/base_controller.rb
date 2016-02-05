class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :restrict_access
  before_action :restrict_access_with_http

  serialization_scope :view_context

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |email, token|
      admin = Admin.find_by(email: email)
      admin && admin.valid_token?(token)
    end
  end
end
