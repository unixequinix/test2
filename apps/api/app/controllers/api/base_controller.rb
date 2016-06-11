class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :restrict_access_with_http

  serialization_scope :view_context
end
