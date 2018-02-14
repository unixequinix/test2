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
      redirect_to(admins_event_path(event), alert: "Access Denied") && return if params[:error]

      uri = URI("https://www.universe.com/oauth/token")
      secret = Figaro.env.universe_client_secret
      client = Figaro.env.universe_client_id
      callback = Figaro.env.universe_app_uri

      res = Net::HTTP.post_form(uri, code: params[:code], grant_type: "authorization_code", client_id: client, client_secret: secret, redirect_uri: callback)
      token = JSON.parse(res.body)["access_token"]

      event.update! universe_token: token
      redirect_to admins_event_universe_path(event), notice: "Universe login successful"
    end

    def webhooks
      JSON.parse(request.body)["cost_items"].to_a.each do |new_ticket|
        events = Event.where(universe_event: new_ticket["event_id"])
        events.each { |event| UniverseImporter.perform_later(new_ticket, event) }
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
