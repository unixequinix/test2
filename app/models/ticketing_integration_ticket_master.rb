class TicketingIntegrationTicketMaster < TicketingIntegration
  belongs_to :event, inverse_of: :ticket_master_ticketing_integrations

  store :data, accessors: %i[userId venue last_import_date], coder: JSON

  attr_accessor :ignore_last_import_date

  def self.policy_class
    TicketingIntegrationPolicy
  end

  def remote_events
    data[:events]&.keys
  end

  def import
    update!(last_import_date: Time.zone.now - 1.minute)
    data[:events].each_pair do |k, v|
      Ticketing::TicketMasterImporter.perform_later(k, v, self)
    end
  end
end
