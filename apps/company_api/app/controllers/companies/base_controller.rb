class Companies::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  serialization_scope :view_context

  # TODO: Get event by token (headers)
  def current_event
    1
  end

  # TODO: Get company name (headers)
  def company_name
    "Ticketmaster"
  end
end
