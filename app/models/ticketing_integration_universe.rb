class TicketingIntegrationUniverse < TicketingIntegration
  belongs_to :event, inverse_of: :universe_ticketing_integrations

  def self.policy_class
    TicketingIntegrationPolicy
  end

  def remote_events
    user_id = api_response(URI(GlownetWeb.config.universe_user_url))["current_user"]["id"]
    data = api_response(URI("#{GlownetWeb.config.universe_listings_url}?user_id=#{user_id}"))

    data["listings"].map do |listing|
      event_data = data["events"].find { |e| e["id"] == listing["event_id"] }
      Hashie::Mash.new listing.merge(event_data)
    end
  end

  def remote_event
    remote_events.find { |e| integration_event_id.eql? e.id }
  end

  def import
    url = URI("#{GlownetWeb.config.universe_barcodes_url}?event_id=#{integration_event_id}")
    data = api_response(url)
    tickets_count, tickets_api_limit = data["meta"].values_at("count", "limit")

    ((tickets_count / tickets_api_limit) + 1).times do |page_number|
      atts = { event_id: integration_event_id, limit: tickets_api_limit, offset: tickets_api_limit * page_number }.to_param
      url = URI("#{GlownetWeb.config.universe_barcodes_url}?#{atts}")
      data = api_response(url)
      data["data"]["guestlist"].each { |ticket| Ticketing::UniverseImporter.perform_later(ticket, self) }
    end
  end
end
