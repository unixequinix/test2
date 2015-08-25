class Events::BaseController < ApplicationController
  helper_method :current_event
  before_action :fetch_current_event
  before_filter :set_i18n_globals

  def current_event
    @current_event || Event.new
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    # @current_event = Event.friendly.find(id)
    @current_event = Event.first
    # TODO User authentication
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end
end