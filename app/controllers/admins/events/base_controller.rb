class Admins::Events::BaseController < Admins::BaseController
  layout "admin_event"
  helper_method :current_event

  after_action :verify_authorized # disable not to raise exception when action does not have authorize method
  around_action :use_time_zone

  private

  def use_time_zone(&block)
    Time.use_zone(current_event.timezone, &block)
  end

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    root_path
  end
end
