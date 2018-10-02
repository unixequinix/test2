module Admins
  class BizzaboController < BaseController
    def auth
      skip_authorization
      event = Event.find_by slug: cookies.signed[:event_slug]
      integration = event.bizzabo_ticketing_integrations.find(cookies.signed[:ticketing_integration_id])

      url = URI("#{GlownetWeb.config.bizzabo_api_url}/events")
      response = integration.api_response(url, {}, GlownetWeb.config.bizzabo_header)
      body = response["error"].blank? ? response["content"] : "ERROR"

      redirect_to([:admins, event, :ticket_types], alert: t("alerts.not_authorized")) && return if body.eql?("ERROR")

      integration.update!(status: "active")
      redirect_to [:admins, event, integration], notice: "Bizzabo login successful"
    end
  end
end
