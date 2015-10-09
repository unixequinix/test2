class Events::SessionsController < Devise::SessionsController
  layout 'event'
  before_filter :configure_permitted_parameters

  def new
    @sign_up = params[:sign_up]
    @confirmed = params[:confirmed]
    @password_sent = params[:password_sent]
    super
  end

  private

  def after_sign_out_path_for(resource)
    event_path(current_event)
  end

  def after_sign_in_path_for(resource)
    event_path(current_event)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :event_id, :remember_me)
    end
  end
end
