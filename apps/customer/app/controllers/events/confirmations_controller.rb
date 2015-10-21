class Events::ConfirmationsController < Devise::ConfirmationsController
  layout 'event'

  private

  def after_confirmation_path_for(resource_name, resource)
    new_customer_event_session_path(current_event, confirmed: true)
  end
end