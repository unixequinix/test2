class Admins::Events::BaseController < Admins::BaseController
  layout 'admin_event'
  before_action :fetch_current_event
  before_filter :set_i18n_globals
  before_filter :enable_fetcher

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    @current_event = Event.find_by_slug(id) if id
    raise ActiveRecord::RecordNotFound if @current_event.nil?
    @current_event
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
