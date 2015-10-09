class Admins::Events::BaseController < Admins::BaseController
  layout 'admin_event'
  before_filter :set_i18n_globals

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    root_path
  end
end
