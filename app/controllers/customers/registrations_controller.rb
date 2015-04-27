class Customers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :surname]
    devise_parameter_sanitizer.for(:account_update) << [:name, :surname]
  end
end
