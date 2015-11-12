class Admins::BaseController < ApplicationController
  layout 'admin'
  protect_from_forgery
  before_action :ensure_admin
  before_action :authenticate_admin!

  helper_method :warden, :admin_signed_in?, :current_admin

  def warden
    request.env['warden']
  end

  def authenticate_admin!
    if current_admin
      redirect_to admin_root_path
    else
      redirect_to new_admins_sessions_path
    end
  end

  def

  def logout_admin!
    warden.logout(:admin)
  end

  def ensure_admin
    unless admin_signed_in?
      logout_admin!
      return false
    end
  end

  def admin_signed_in?
    !current_admin.nil?
  end

  def current_admin
    if warden.authenticated?(:admin)
      @current_admin ||= Admin.find(warden.user(:admin)["id"]) unless
        warden.user(:admin).nil? ||
        Admin.where(id: warden.user(:admin)["id"]).empty?
    else
      @current_admin = warden.authenticate(:admin_password, scope: :admin)
    end
  end
end
