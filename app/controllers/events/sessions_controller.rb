class Events::SessionsController < Devise::SessionsController
  include LanguageHelper

  before_action :resolve_locale
  before_action :set_event
  before_action :check_customer_confirmation, only: [:create]

  layout "customer"

  def create
    resource = warden.authenticate!(auth_options)
    sign_in(resource)

    set_flash_message!(:notice, :signed_in)
    redirect_to after_sign_in_path_for(resource)
  end

  private

  def after_sign_in_path_for(resource)
    customer_root_path(resource.event)
  end

  def after_sign_out_path_for(_resource)
    event_login_path(@current_event)
  end

  def check_customer_confirmation
    customer = Customer.find_by_email(sign_in_params[:email])

    if customer.confirmed?
      return 
    else 
      flash[:error] = t('sessions.log_in.unconfirmed_error')
      expire_data_after_sign_in!
      redirect_to request.path
    end
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
