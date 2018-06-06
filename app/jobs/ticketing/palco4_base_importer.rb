module Ticketing
  class Palco4BaseImporter < ApplicationJob
    queue_as :default

    def perform(tickets, integration)
      tickets&.group_by { |ticket| [ticket["zoneId"], ticket["zoneName"]] }.each do |arr, sub_tickets|
        company_code, name = arr
        company = integration.class.to_s.gsub("TicketingIntegration", "")
        ticket_type = integration.ticket_types.find_or_create_by!(company: company, company_code: company_code, event_id: integration.event_id, name: name)

        Palco4Importer.perform_later(sub_tickets, integration, ticket_type)
      end
    end
  end
end
