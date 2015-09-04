class Events::DeviseBaseController < ApplicationController
  layout 'event'
  helper_method :current_event
  before_action :fetch_current_event
  before_action :authenticate_customer!

  def current_customer_event_profile
    # TODO fix the first event invocation
    current_customer.customer_event_profiles.for_event(current_event).first ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  def current_event
    @current_event || Event.new
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    @current_event = Event.friendly.find(id)
  end

  def authenticate_customer!
    redirect_to new_event_session_path(current_event), notice: 'if you want to add a notice' unless current_customer
  end

  # Attempt to find the mapped route for devise based on request path
  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"]
  end

  # Helper for use after calling send_*_instructions methods on a resource.
  # If we are in paranoid mode, we always act as if the resource was valid
  # and instructions were sent.
  def successfully_sent?(resource)
    notice = if Devise.paranoid
      resource.errors.clear
      :send_paranoid_instructions
    elsif resource.errors.empty?
      :send_instructions
    end

    if notice
      set_flash_message :notice, notice if is_flashing_format?
      true
    end
  end

  # Sets the flash message with :key, using I18n. By default you are able
  # to setup your messages using specific resource scope, and if no message is
  # found we look to the default scope. Set the "now" options key to a true
  # value to populate the flash.now hash in lieu of the default flash hash (so
  # the flash message will be available to the current action instead of the
  # next action).
  # Example (i18n locale file):
  #
  #   en:
  #     devise:
  #       passwords:
  #         #default_scope_messages - only if resource_scope is not found
  #         user:
  #           #resource_scope_messages
  #
  # Please refer to README or en.yml locale file to check what messages are
  # available.
  def set_flash_message(key, kind, options = {})
    message = find_message(kind, options)
    if options[:now]
      flash.now[key] = message if message.present?
    else
      flash[key] = message if message.present?
    end
  end

  # Sets minimum password length to show to user
  def set_minimum_password_length
    @minimum_password_length = Devise.password_length.min
  end

  def devise_i18n_options(options)
    options
  end

  # Get message for given
  def find_message(kind, options = {})
    options[:scope] ||= translation_scope
    options[:default] = Array(options[:default]).unshift(kind.to_sym)
    options[:resource_name] = 'Customer'
    options = devise_i18n_options(options)
    I18n.t("#{options[:resource_name]}.#{kind}", options)
  end

  # Controllers inheriting DeviseController are advised to override this
  # method so that other controllers inheriting from them would use
  # existing translations.
  def translation_scope
    "devise.#{controller_name}"
  end

  def clean_up_passwords(object)
    object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
  end

  def respond_with_navigational(*args, &block)
    respond_with(*args) do |format|
      format.any(*navigational_formats, &block)
    end
  end

  def resource_params
    params.fetch(resource_name, {})
  end

  def create_customer_event_profile(customer)
    customer_event_profile =
      CustomerEventProfile.find_by(customer: customer, event: current_event) ||
      customer.customer_event_profiles.build(event: current_event)
    customer_event_profile.save unless customer_event_profile.persisted?
  end
end