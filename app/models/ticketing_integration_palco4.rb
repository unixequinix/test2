class TicketingIntegrationPalco4 < TicketingIntegration
  belongs_to :event, inverse_of: :palco4_ticketing_integrations

  store :data, accessors: %i[userId venue last_import_date], coder: JSON

  attr_accessor :ignore_last_import_date

  def self.policy_class
    TicketingIntegrationPalco4
  end

  def import
    params = { sessions: integration_event_id }
    params = params.merge(date: last_import_date) if last_import_date && !ignore_last_import_date
    url = URI("#{GlownetWeb.config.palco4_barcodes_url}?#{params.to_param}")

    update!(last_import_date: Time.zone.now - 1.minute)

    response = api_response(url)
    response&.each { |ticket| Ticketing::Palco4Importer.perform_later(ticket, self) }
  end
end
