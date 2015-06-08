class Customers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  private

  def after_inactive_sign_up_path_for(resource)
    new_customer_session_path(sign_up: true)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :surname, :agreed_on_registration]
    devise_parameter_sanitizer.for(:account_update) << [:name, :surname, :agreed_on_registration]
  end
end
