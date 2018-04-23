module Admins
  class UniverseController < BaseController
    # this method is here because all auth sessions redirect to a common action (this one).
    # this allows to being able to create only one common app in Universe
    skip_before_action :verify_authenticity_token, :authenticate_user!, only: :webhooks
    before_action :validate_universe, only: :webhooks
    after_action :verify_authorized, except: %i[webhooks validate_universe]

    def auth
      skip_authorization
      event = Event.find_by slug: cookies.signed[:event_slug]
      integration = event.universe_ticketing_integrations.find(cookies.signed[:ticketing_integration_id])

      redirect_to(admins_event_path(event), alert: "Access Denied") && return if params[:error]

      uri = URI("https://www.universe.com/oauth/token")
      client = Figaro.env.universe_client_id
      secret = Figaro.env.universe_client_secret
      callback = "https://glownet.ngrok.io/admins/universe/auth"
      res = Net::HTTP.post_form(uri, code: params[:code], grant_type: "authorization_code", client_id: client, client_secret: secret, redirect_uri: callback)
      token = JSON.parse(res.body)["access_token"]

      integration.update! token: token
      redirect_to [:admins, event, integration], notice: "Universe login successful"
    end

    def webhooks
      JSON.parse(request.body)["cost_items"].to_a.each do |new_ticket|
        integrations = TicketingIntegration.where(integration_event_id: new_ticket["event_id"], status: "active", event: Event.launched)
        integrations.each { |integration| UniverseImporter.perform_later(new_ticket, integration) }
      end
      head(:ok)
    end

    private

    def validate_universe
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Figaro.env.universe_webhooks_secret, request.body.read)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.headers["X-Uniiverse-Signature"])
    end
  end
end
