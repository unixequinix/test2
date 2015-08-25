class Admins::Events::BaseController < Admins::BaseController
  layout 'admin_event'
  before_filter :set_i18n_globals

  private

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end
end
