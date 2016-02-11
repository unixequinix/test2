class Admins::Events::BaseController < Admins::BaseController
  layout "admin_event"
  before_action :fetch_current_event
  before_filter :set_i18n_globals
  before_filter :enable_fetcher
  helper_method :current_event

  def current_event
    @current_event.decorate || Event.new.decorate
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    return false unless id
    @current_event = Event.find_by_slug(id) || Event.find(id) if id
  end

  def enable_fetcher
    @fetcher = Multitenancy::AdministrationFetcher.new(current_event)
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    root_path
  end
end
