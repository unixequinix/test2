module Admins
  class StubhubController < BaseController
    def auth
      skip_authorization
      event = Event.find_by slug: cookies.signed[:event_slug]
      integration = event.stubhub_ticketing_integrations.find(cookies.signed[:ticketing_integration_id])

      url = URI(GlownetWeb.config.stubhub_auth_url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request.basic_auth(integration.client_key, integration.client_secret)
      response = http.request(request)
      body = JSON.parse(response.body)

      redirect_to([:admins, event, :ticket_types], alert: t("alerts.not_authorized")) && return if body.eql?("ERROR")

      integration.update!(token: body["token"], userId: body["userId"], status: "active")
      redirect_to [:admins, event, integration], notice: "Stubhub login successful"
    end
  end
end
