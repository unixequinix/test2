module Admins
  class BaseController < ApplicationController
    layout "admin"

    before_action :set_paper_trail_whodunnit
    before_action :authenticate_user!
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    after_action :verify_authorized # disable not to raise exception when action does not have authorize method
  end
end
