class Admins::Events::PaymentsBaseController < ::Admins::Events::BaseController
  layout 'admin_event'
  before_filter :set_i18n_globals
  before_filter :enable_fetcher

  private

  def enable_fetcher
    @fetcher = Multitenancy::PaymentFetcher.new(current_event)
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    root_path
  end
end
