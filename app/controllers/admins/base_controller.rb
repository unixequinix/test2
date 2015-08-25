class Admins::BaseController < ApplicationController
  helper_method :current_event
  before_action :authenticate_admin!
  before_action :fetch_current_event
  layout 'admin'

  # TODO Do this somewhere else other than the global space
  def current_event
    @current_event || Event.new
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    @current_event = Event.friendly.find(id) if id
    # TODO User authentication
  end
end
