class Events::SessionsController < Devise::SessionsController
  include LanguageHelper

  before_action :set_event
  before_action :resolve_locale

  skip_before_action :verify_authenticity_token
  layout "customer"

  before_action :check_captcha, only: :create
  before_action :check_user_confirmation, only: :create
  before_action :reset_captcha, only: :destroy

  def send_email
    user = @current_event.customers.find_by(email: sign_in_params[:email])
    if user
      user.resend_confirmation_instructions
      redirect_to customer_root_path(@current_event)
    else
      redirect_to event_resend_confirmation_path(@current_event), alert: "Account does not exists"
    end
  end

  def resend_confirmation
    self.resource = resource_class.new
  end

  def create
    super
  end

  def destroy
    super
  end

  private

  def check_captcha
    verify_recaptcha_if_under_attack
  end

  def reset_captcha
    Rack::Attack.reset_throttle("/:event/login", current_customer)
  end

  def check_user_confirmation
    user = @current_event.customers.find_by(email: sign_in_params[:email])
    return unless user

    redirect_to event_resend_confirmation_path(@current_event), alert: t('sessions.log_in.account_error') unless user.confirmed?
  end

  def after_sign_in_path_for(resource)
    flash[:notice] = t('sessions.log_in.success', event: resource.event.name)
    customer_root_path(resource.event)
  end

  def after_sign_out_path_for(_resource)
    flash[:notice] = t('sessions.log_out.success')
    event_login_path(@current_event)
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
