module Ticketing
  class UniverseImporter < ApplicationJob
    queue_as :default

    def perform(ticket, integration)
      ticket = Hashie::Mash.new ticket

      if ticket.event_id.present?
        company_code = ticket.rate_id
        ticket_name = ticket.name
        ticket_price = ticket.price.to_f
        ticket_code = ticket.qr_code
        first_name = ticket.guest_first_name
        last_name = ticket.guest_last_name
        email = ticket.guest_email
      else
        company_code = ticket.ticket_type.id
        ticket_name = ticket.ticket_type.name
        ticket_price = ticket.ticket_type.price.to_f
        ticket_code = ticket.token
        first_name = ticket.answers.first.value
        last_name = ticket.answers.second.value
        email = ticket.answers.third.value
      end

      ticket_type = integration.ticket_types.find_or_initialize_by(company_code: company_code, event_id: integration.event_id)
      ticket_type.update!(name: ticket_name, company: "Universe")
      new_ticket = ticket_type.tickets.find_or_initialize_by(code: ticket_code, event_id: integration.event_id)
      new_ticket.update!(ticket_type: ticket_type, purchaser_first_name: first_name, purchaser_last_name: last_name, purchaser_email: email)
    end
  end
end
