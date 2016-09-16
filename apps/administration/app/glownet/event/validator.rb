class Event::Validator
  def initialize(event)
    @event = event
    @errors = {}
  end

  def check_ticket_types
    company_codes = event.company_ticket_types.map(&:company_code)
    credentials = event.company_ticket_types.map(&:credential_type_id)
    @errors[:company_ticket_types] < "Set the company codes" if company_codes.size != company_codes.compact.size
    @errors[:company_ticket_types] < "Set the credential types" if credentials.size != credentials.compact.size
  end
end
