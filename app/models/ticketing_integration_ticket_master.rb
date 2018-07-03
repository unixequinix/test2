class TicketingIntegrationTicketMaster < TicketingIntegration
  belongs_to :event, inverse_of: :ticket_master_ticketing_integrations

  store :data, accessors: %i[userId venue last_import_date], coder: JSON

  attr_accessor :ignore_last_import_date

  def self.policy_class
    TicketingIntegrationPolicy
  end

  def import
    if event.is_ticketmaster?
      update!(last_import_date: Time.zone.now - 1.minute)
      [{ 5327 => 'Barcelona Beach Festival' }, { 5333 => 'Barcelona Beach Festival - VIP Experience' }, { 5329 => 'Barcelona Beach Festival - Premium' }].each do |hash|
        event_id = hash.keys[0]
        ticket_type_name = hash.values[0]

        Ticketing::TicketMasterImporter.perform_later(event_id, ticket_type_name, self)
      end
    end
  end
end
