class Companies::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :restrict_access_with_http
  serialization_scope :view_context

  attr_reader :current_event

  attr_reader :current_company

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |company, token|
      @current_event = Event.find_by(token: token)
      @current_company = Company.find_by(name: company, event: @current_event)
      @current_event && @current_company
    end
  end
end
