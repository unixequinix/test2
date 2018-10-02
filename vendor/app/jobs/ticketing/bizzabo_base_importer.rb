module Ticketing
  class BizzaboBaseImporter < ApplicationJob
    queue_as :critical

    def perform(response, integration)
      company = integration.class.to_s.gsub("TicketingIntegration", "")
      return if response.try(:[], "content").blank?

      ticket_types = response["content"].map { |ticket_type| [ticket_type["name"], ticket_type["id"]] }.to_h
      ticket_types.each do |name, ticket_type_id|
        paginate_tickets(0, integration, company, name, ticket_type_id)
      end
    end

    private

    # updated tickets are new tickets or updated existing tickets???
    def paginate_tickets(page, integration, company, name, ticket_type_id)
      url = URI("#{GlownetWeb.config.bizzabo_api_url}/registrations?filter=ticketId=#{ticket_type_id}&sort=id,asc&size=200&page=#{page}")
      response = integration.api_response(url, {}, GlownetWeb.config.bizzabo_header)
      tickets = response["content"]
      return if tickets.blank?

      page += 1
      ticket_type = integration.ticket_types.find_or_create_by!(company: company, company_code: ticket_type_id, event_id: integration.event_id, name: name)
      values = tickets.map { |ticket| [integration.event_id, ticket_type.id, ticket["id"], ticket["checkedin"]] }
      Palco4Importer.perform_later(values)

      if page
        paginate_tickets(page, integration, company, name, ticket_type_id) unless response["page"]["totalPages"].eql?(response["page"]["number"])
      end
    end
  end
end
