class Customers::PasswordsController < Devise::PasswordsController

  private

  def after_sending_reset_password_instructions_path_for(resource)
    new_customer_session_path(password_sent: true)
  end
end
