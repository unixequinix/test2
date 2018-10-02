class TicketingIntegrationBizzabo < TicketingIntegration
  belongs_to :event, inverse_of: :bizzabo_ticketing_integrations
  store :data, accessors: %i[last_import_date], coder: JSON

  attr_accessor :ignore_last_import_date

  def self.policy_class
    TicketingIntegrationPolicy
  end

  def remote_events
    api_response(URI("#{GlownetWeb.config.bizzabo_api_url}/events"), {}, GlownetWeb.config.bizzabo_header)["content"]
  end

  def remote_event
    Hashie::Mash.new(remote_events.find { |e| e["id"].eql? integration_event_id.to_i })
  end

  def import
    params = { sessions: integration_event_id }
    params = params.merge(date: last_import_date) if last_import_date && !ignore_last_import_date
    paginate_ticket_types(0, integration_event_id)
  end

  private

  def paginate_ticket_types(page, integration_event_id)
    url = URI("#{GlownetWeb.config.bizzabo_api_url}/registrationTypes?eventId=#{integration_event_id}&sort=id,asc&size=200&page=#{page}")
    response = api_response(url, {}, GlownetWeb.config.bizzabo_header)
    page += 1
    Ticketing::BizzaboBaseImporter.perform_later(response, self)

    if page
      paginate_ticket_types(page, integration_event_id) unless response["page"]["totalPages"].eql?(response["page"]["number"])
    end
  end
end
