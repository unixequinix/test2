module Ticketing
  class Palco4BaseImporter < ApplicationJob
    queue_as :critical

    def perform(tickets, integration)
      tickets.to_a.group_by { |ticket| [ticket["zoneId"], ticket["zoneName"]] }.each do |arr, sub_tickets|
        company_code, name = arr
        company = integration.class.to_s.gsub("TicketingIntegration", "")
        ticket_type = integration.ticket_types.find_or_create_by!(company: company, company_code: company_code, event_id: integration.event_id, name: name)
        values = sub_tickets.map { |ticket| [integration.event_id, ticket_type.id, ticket["code"], !ticket["statusId"].to_i.zero?] }

        Palco4Importer.perform_later(values)
      end
    end
  end
end
