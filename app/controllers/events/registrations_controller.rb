class Events::RegistrationsController < Devise::RegistrationsController
  layout "customer"
  helper_method :current_event
  before_action :configure_permitted_parameters
  helper_method :current_customer

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def build_resource(*args)
    super
    return unless session[:omniauth]

    token = Devise.friendly_token[0, 20]
    name = session[:omniauth]["info"]["name"].split(" ")
    first_name = session[:omniauth]["info"]["first_name"] || name.first
    last_name = session[:omniauth]["info"]["last_name"] || name.second
    resource.event = @current_event
    resource.provider = session[:omniauth]["provider"]
    resource.uid = session[:omniauth]["uid"]
    resource.email = session[:omniauth]["info"]["email"]
    resource.first_name = first_name
    resource.last_name = last_name
    resource.password = token
    resource.password_confirmation = token
    resource.agreed_on_registration = true
    session.delete(:omniauth) && resource.valid?
  end

  def configure_permitted_parameters
    customer = %i(first_name last_name phone postcode address city country gender birthdate provider uid agreed_on_registration)

    devise_parameter_sanitizer.permit(:account_update, keys: customer)
    devise_parameter_sanitizer.permit(:sign_up, keys: customer)
  end

  def after_update_path_for(_resource)
    customer_root_path(current_event)
  end

  def after_sign_up_path_for(_resource)
    customer_root_path(current_event)
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def current_event
    params[:event_id] ||= params[:id]
    @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
  end
end
