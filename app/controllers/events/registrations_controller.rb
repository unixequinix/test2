class Events::RegistrationsController < Devise::RegistrationsController
  layout 'event'
  before_filter :configure_permitted_parameters

  private

  def after_inactive_sign_up_path_for(resource)
    new_customer_event_session_path(current_event, sign_up: true)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, :name, :surname,
        :address, :city, :country, :postcode, :gender, :birthdate, :event_id,
        :agreed_on_registration)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :password, :password_confirmation, :current_password,
        :name, :surname, :address, :city, :country, :postcode, :gender,
        :birthdate, :event_id, :agreed_on_registration)
    end
  end
end
