module Admins
  class PasswordsController < Devise::PasswordsController
    layout "welcome_admin"

    private

    def after_resetting_password_path_for(resource)
      stored_location_for(resource) || admins_events_path
    end

    def after_sending_reset_password_instructions_path_for(_resource_name)
      new_user_session_path
    end
  end
end
