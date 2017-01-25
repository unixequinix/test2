class Admins::Events::BaseController < Admins::BaseController
  layout "admin_event"
  before_action :fetch_current_event
  helper_method :current_event

  private

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    root_path
  end
end
