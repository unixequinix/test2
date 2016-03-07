class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :restrict_access_with_http

  serialization_scope :view_context
end
