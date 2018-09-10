module Admins
  class SessionsController < Devise::SessionsController
    layout "welcome_admin"
    before_action :skip_authorization
    before_action :check_captcha, only: :create
    before_action :reset_captcha, only: :destroy

    def create
      super
    end

    def destroy
      super
    end

    private

    def check_captcha
      render :new unless verify_recaptcha_if_under_attack
    end

    def reset_captcha
      Rack::Attack.reset_throttle("/users/sign_in", current_user)
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || admins_events_path
    end

    def after_sign_out_path_for(_resource)
      new_user_session_path
    end
  end
end
