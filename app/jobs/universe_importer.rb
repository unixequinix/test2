class UniverseImporter < ApplicationJob
  def perform(ticket, event_id)
    ticket = Hashie::Mash.new ticket

    if ticket.event_id.present?
      # webhooks
      begin
        company = Company.find_or_create_by(name: "Universe - #{ticket.event_id}", event_id: event_id)
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      begin
        ctt = TicketType.find_or_initialize_by(company: company, company_code: ticket.rate_id, event_id: event_id)
        ctt.update(name: ticket.name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      begin
        cticket = Ticket.find_or_initialize_by(code: ticket.qr_code, ticket_type: ctt, event_id: event_id)
        cticket.update(created_at: ticket.created_at)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      cticket.update!(purchaser_first_name: ticket.guest_first_name, purchaser_last_name: ticket.guest_last_name, purchaser_email: ticket.guest_email)
    else
      # import_tickets
      begin
        company = Company.find_or_create_by(name: "Universe - #{ticket.event.id}", event_id: event_id)
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      profile = ticket.answers
      begin
        ctt = TicketType.find_or_initialize_by(company: company, company_code: ticket.ticket_type.id, event_id: event_id)
        ctt.update(name: ticket.ticket_type.name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      begin
        cticket = Ticket.find_or_initialize_by(code: ticket.token, ticket_type: ctt, event_id: event_id)
        cticket.update(created_at: ticket.created_at)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      cticket.update!(purchaser_first_name: profile[0].value, purchaser_last_name: profile[1].value, purchaser_email: profile[2].value)
    end
  end
end
