module TransactionsHelper
  def create_gtag(tag_uid, event_id)
    # ticket_activation transactions dont have tag_uid
    return unless tag_uid

    Gtag.find_or_create_by(tag_uid: tag_uid, event_id: event_id)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def decode_ticket(code, event)
    return unless code

    # Ticket is not found. perhaps is new sonar ticket?
    id = SonarDecoder.valid_code?(code) && SonarDecoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.ticket_types.find_by(company_code: id)

    begin
      ticket = event.tickets.find_or_create_by(code: code, ticket_type: ctt)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    ticket
  end
end
