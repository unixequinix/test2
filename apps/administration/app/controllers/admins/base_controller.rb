class Admins::BaseController < ApplicationController
  layout 'admin'
  protect_from_forgery
  before_action :authenticate_admin!

  helper_method :warden, :admin_signed_in?, :current_admin

  def admin_signed_in?
    !current_admin.nil?
  end

  def current_admin
    @current_admin ||= Admin.find(warden.user(:admin)["id"]) unless warden.user(:admin).nil?
  end

  def warden
    request.env['warden']
  end

  def authenticate_admin!
    warden.authenticate!(:admin_password, scope: :admin)
  end
end
