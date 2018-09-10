class Companies::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  serialization_scope :view_context
end
