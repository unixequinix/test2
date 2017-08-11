class Events::ConfirmationsController < Devise::ConfirmationsController
  before_action :set_event

  layout "customer"

  private

  def after_confirmation_path_for(_resource_name, resource)
    if resource.confirmed?
      sign_in(resource)
    else
      set_flash_message! :notice, t('email.confirmation.error')
    end

    customer_root_path(@current_event)
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
