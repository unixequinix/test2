module Admins
  class EventbriteController < BaseController
    # this method is here because all auth sessions redirect to a common action (this one).
    # this allows to being able to create only one common app in Eventbrite
    def auth
      skip_authorization
      event = Event.find_by slug: cookies.signed[:event_slug]
      redirect_to([:admins, event, :ticket_types], alert: "Access Denied") && return if params[:error]

      uri = URI("https://www.eventbrite.com/oauth/token")
      secret = GlownetWeb.config.eventbrite_client_secret
      client = GlownetWeb.config.eventbrite_client_id

      res = Net::HTTP.post_form(uri, code: params[:code], client_secret: secret, client_id: client, grant_type: "authorization_code")
      token = JSON.parse(res.body)["access_token"]

      integration = event.eventbrite_ticketing_integrations.find(cookies.signed[:ticketing_integration_id])
      integration.update! token: token
      redirect_to [:admins, event, integration], notice: "Eventbrite login successful"
    end
  end
end
