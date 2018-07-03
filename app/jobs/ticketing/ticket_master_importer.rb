module Ticketing
  class TicketMasterImporter < ApplicationJob
    queue_as :default

    def perform(event_id, ticket_type_name, integration)
      if integration.data[event_id.to_s].blank?
        integration.data[event_id.to_s] = 1
        integration.save
      end

      offset = integration.data[event_id.to_s]
      uri = URI(GlownetWeb.config.ticketmaster_url_1.to_s)
      request_body = GlownetWeb.config.ticket_master_params.merge(command1: { event_id: event_id, entry_code_offset: offset })
      tickets = TicketingIntegration.new.api_response(uri, request_body)['command1']['entry_codes']

      until tickets.blank? || tickets.last.try(:[], 'entry_code_offset').eql?(integration.data[event_id.to_s].to_i)
        integration_offset = integration.data[event_id.to_s]
        ticket_type = integration.event.ticket_types.find_or_create_by!(company: 'TicketMaster', company_code: "TM#{event_id}", ticketing_integration_id: integration.id, event_id: integration.event_id, name: ticket_type_name)
        tickets.map { |t| { offset: t['entry_code_offset'], code: t["entry_code_info"]["value"], banned: !t["status"].eql?("ACTIVE") } }.each do |hash|
          ticket = integration.event.tickets.find_or_create_by!(ticket_type: ticket_type, code: hash[:code])
          ticket.update(banned: hash[:banned])
          integration_offset = (hash[:offset].to_i + 1)
        end
        integration.data[event_id.to_s] = integration_offset
        integration.save

        request_body = GlownetWeb.config.ticket_master_params.merge(command1: { event_id: event_id, entry_code_offset: integration.reload.data[event_id.to_s] })
        tickets = TicketingIntegration.new.api_response(uri, request_body)['command1']['entry_codes']
      end
    end
  end
end
