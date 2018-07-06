class Events::RegistrationsController < Devise::RegistrationsController
  include LanguageHelper

  before_action :resolve_locale
  before_action :configure_permitted_parameters
  before_action :set_event

  layout "customer"

  def create
    build_resource(sign_up_params)

    if verify_recaptcha(model: resource) && resource.save
      redirect_to customer_event_session_path(@current_event), notice: t('email.confirmation.flash_message')
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  def update
    if @current_customer.update_without_password(account_update_params)
      bypass_sign_in(@current_customer)
      redirect_to customer_root_path(@current_event), notice: t("alerts.updated")
    else
      render :edit
    end
  end

  def update_password
    if @current_customer.update(password_params)
      bypass_sign_in(@current_customer)
      redirect_to customer_root_path(@current_event), notice: t("alerts.updated")
    else
      render :change_password
    end
  end

  private

  def build_resource(hash = {}) # rubocop:disable Metrics/AbcSize
    self.resource = session[:customer_id] ? @current_event.customers.find(session[:customer_id]) : @current_event.customers.new
    resource.attributes = hash.merge(anonymous: false, locale: I18n.locale)

    return unless session[:omniauth]

    token = Devise.friendly_token[0, 20]
    name = session[:omniauth]["info"]["name"]&.split(" ")
    first_name = session[:omniauth]["info"]["first_name"] || name.first
    last_name = session[:omniauth]["info"]["last_name"] || name.second
    resource.provider = session[:omniauth]["provider"]
    resource.uid = session[:omniauth]["uid"]
    resource.email = session[:omniauth]["info"]["email"]
    resource.first_name = first_name
    resource.last_name = last_name
    resource.password = token
    resource.password_confirmation = token
    resource.agreed_on_registration = true
    resource.anonymous = false
    resource.locale = I18n.locale
    session.delete(:omniauth) && resource.valid?
  end

  def after_update_path_for(_resource)
    customer_root_path(@current_event)
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
    @current_customer = current_customer
  end

  def configure_permitted_parameters
    customer = %i[first_name last_name phone postcode address city country gender birthdate provider uid agreed_on_registration gdpr_acceptance]

    devise_parameter_sanitizer.permit(:account_update, keys: customer)
    devise_parameter_sanitizer.permit(:sign_up, keys: customer)
  end

  def password_params
    params.require(:customer).permit(:password, :password_confirmation)
  end
end
