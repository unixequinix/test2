class Events::SessionsController < Devise::SessionsController
  include LanguageHelper

  before_action :set_event
  before_action :resolve_locale
  before_action :check_customer_confirmation, only: [:create]

  layout "customer"

  def create
    resource = warden.authenticate!(auth_options)

    if sign_in(resource)
      yield resource if block_given?
      message = { notice: t('sessions.log_in.success', event: @current_event.name) }
    else
      message = { alert: t('sessions.log_in.account_error') }
    end

    redirect_to after_sign_in_path_for(resource), message
  end

  private

  def after_sign_in_path_for(resource)
    customer_root_path(resource.event)
  end

  def after_sign_out_path_for(_resource)
    flash[:notice] = t('sessions.log_out.success')
    event_login_path(@current_event)
  end

  def check_customer_confirmation
    customer = @current_event.customers.find_by(email: sign_in_params[:email])
    return if customer&.confirmed?

    expire_data_after_sign_in!
    redirect_to event_login_path(customer&.event || @current_event), alert: t('sessions.log_in.account_error')
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
