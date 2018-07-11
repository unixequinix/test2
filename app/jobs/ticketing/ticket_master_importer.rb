module Ticketing
  class TicketMasterImporter < ApplicationJob
    queue_as :default

    def perform(event_code, event_data, integration) # rubocop:disable Metrics/AbcSize
      uri = URI(GlownetWeb.config.ticketmaster_url_1.to_s)
      request_body = GlownetWeb.config.ticket_master_params_1.merge(command1: {
                                                                      access_control_system: event_data[:access_control_system],
                                                                      filters: {
                                                                        included_event: [{ event_code: event_code, event_year: event_data[:begin_date].to_date.year }],
                                                                        system_id: event_data[:system_id],
                                                                        date_interval: {
                                                                          begin_date: event_data[:begin_date].to_date.strftime('%F'),
                                                                          end_date: event_data[:end_date].to_date.strftime('%F')
                                                                        }
                                                                      }
                                                                    })

      response = TicketingIntegration.new.api_response(uri, request_body)
      if response['command1']['events'].present?
        event_id = response['command1']['events'][0]['event_id']
        company = response['command1']['events'][0]['title']
        ticket_types_data = response['command1']['events'][0]['price_types'].each_with_object({}) { |pt, hash| hash[(pt['extended_ids']).to_s] = { name: pt['name'], code: pt['code'] } }
        ticket_types_data.values.map { |tt| integration.ticket_types.find_or_create_by!(company: company, company_code: tt[:code], ticketing_integration_id: integration.id, event_id: integration.event_id, name: tt[:name].gsub("á", "a").gsub("é", "e").gsub("í", "i").gsub("ó", "o").gsub("ú", "u")) }
        request_body = GlownetWeb.config.ticket_master_params_2.merge(command1: { event_id: event_id, entry_code_offset: (event_data[:offset] || 1) })
      end

      tickets = event_id.nil? ? [] : TicketingIntegration.new.api_response(uri, request_body)['command1']['entry_codes']
      integration_offset = integration.data[:events][event_code][:offset]&.to_i

      until tickets.blank? || tickets.last.try(:[], 'entry_code_offset').eql?(integration.data[:events][event_code][:offset].to_i - 1)
        tickets.map { |t| { offset: (t['entry_code_offset'].to_i + 1), code: t["entry_code_info"]["value"], banned: !t["status"].eql?("ACTIVE"), index: t["price_type"].to_i } }.each do |hash|
          index = 0
          ticket_types_data.keys.each { |i| index = i if JSON.parse(i).include?(hash[:index]) }
          ticket_type = integration.ticket_types.find_by(company_code: ticket_types_data[index][:code])
          ticket = integration.event.tickets.find_or_create_by!(ticket_type: ticket_type, code: hash[:code])
          ticket.update(banned: hash[:banned])
          integration_offset = hash[:offset]
        end

        integration.data[:events][event_code][:offset] = integration_offset
        integration.save!

        request_body = GlownetWeb.config.ticket_master_params_2.merge(command1: { event_id: event_id, entry_code_offset: integration.data[:events][event_code][:offset] })
        tickets = TicketingIntegration.new.api_response(uri, request_body)['command1']['entry_codes']
      end
    end
  end
end
