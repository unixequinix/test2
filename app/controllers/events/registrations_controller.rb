class Events::RegistrationsController < Devise::RegistrationsController
  layout "customer"
  helper_method :current_event
  before_action :configure_permitted_parameters
  helper_method :current_profile

  def update_password
    if current_customer.update_with_password(profile_params)
      bypass_sign_in current_customer
      redirect_to after_update_path_for(current_customer)
    else
      render :change_password
    end
  end

  private

  def current_profile
    current_customer.profile || Profile.new(customer: current_customer, event: current_event)
  end

  def configure_permitted_parameters
    customer = [:first_name, :last_name, :phone, :postcode, :address, :city, :country, :gender, :birthdate,
                :agreed_on_registration, :agreed_event_condition, :receive_communications]

    devise_parameter_sanitizer.permit(:account_update, keys: customer)
    devise_parameter_sanitizer.permit(:sign_up, keys: customer)
  end

  def profile_params
    params.require(:customer).permit(:password, :password_confirmation, :current_password)
  end

  def after_update_path_for(_resource)
    customer_root_path(current_event)
  end

  def after_sign_up_path_for(_resource)
    customer_root_path(current_event)
  end

  def current_event
    id = params[:event_id] || params[:id]
    return false unless id
    Event.find_by_slug(id) || Event.find(id) if id
  end
end
