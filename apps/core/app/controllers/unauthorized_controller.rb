class UnauthorizedController < ActionController::Base
  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers

  delegate :flash, to: :request

  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    # unless request.get?
    #   message = env["warden"].message[:message]
    #   flash.alert = I18n.t(message)
    # end

    handle_response || render(status: :unauthorized, json: :unauthorized)
  end

  private

  def handle_response
    redirect_to(send("scope_#{scope}_url")) && return if scope.present?
    render(status: :unauthorized, json: :unauthorized)
  end

  def scope_customer_url
    event_id = params[:event_id].nil? ? params[:id] : params[:event_id]
    @route = event_login_url(event_id: event_id) if scope == :customer
  end

  def scope_admin_url
    @route = new_admins_sessions_url if scope == :admin
  end

  def warden_options
    env["warden.options"]
  end

  def scope
    @scope ||= warden_options[:scope]
  end
end
