module Admins
  class QwantiqController < BaseController
    def auth
      skip_authorization
      event = Event.find_by slug: cookies.signed[:event_slug]
      integration = event.qwantiq_ticketing_integrations.find(cookies.signed[:ticketing_integration_id])

      url = URI(GlownetWeb.config.qwantiq_auth_url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request.basic_auth(integration.client_key, integration.client_secret)
      response = http.request(request)
      body = response.body.eql?("ERROR") ? response.body : JSON.parse(response.body)

      redirect_to([:admins, event, :ticket_types], alert: t("alerts.not_authorized")) && return if body.eql?("ERROR")

      integration.update!(token: body, status: "active")
      redirect_to [:admins, event, integration], notice: "Qwantiq login successful"
    end
  end
end
