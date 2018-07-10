class TicketingIntegrationTicketMaster < TicketingIntegration
  belongs_to :event, inverse_of: :ticket_master_ticketing_integrations
  before_save :set_events


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

  private

  def set_events
    integration = event.ticketing_integrations.find_or_initialize_by(integration_event_name: event.name, type: TicketingIntegration::NAMES[:ticket_master], token: nil)
    integration.integration_event_id = nil
    integration.data[:events] = { "#{data[:event_code]}": {} } if integration.new_record?
    integration.data[:events] = integration.data[:events].merge("#{data[:event_code]}": {
                                                                    begin_date: data[:begin_date],
                                                                    end_date: data[:end_date],
                                                                    access_control_system: data[:access_control_system],
                                                                    system_id: data[:system_id]
                                                                  })
    if new_record?
      integration.destroy 
      self.id = integration&.id
      self.attributes = integration.attributes
    end
  end
end
