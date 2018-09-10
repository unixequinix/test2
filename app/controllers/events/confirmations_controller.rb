class Events::ConfirmationsController < Devise::ConfirmationsController
  include LanguageHelper

  before_action :set_event
  before_action :resolve_locale

  layout "customer"

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.valid? && resource.errors.empty?
      redirect_to after_confirmation_path_for(resource)
    else
      redirect_to event_login_path(@current_event), alert: t('sessions.log_in.account_error')
    end
  end

  private

  def after_confirmation_path_for(resource)
    if current_customer.blank?
      sign_in(resource)

      flash.delete(:notice)
      customer_root_path(@current_event)
    else
      flash[:notice] = t('sessions.log_in.confirmed_not_logged_error')
      event_login_path(@current_event)
    end
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
