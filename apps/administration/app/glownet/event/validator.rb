class Event::Validator
  attr_reader :errors

  def initialize(event)
    @event = event
    @errors = []
  end

  def all
    v = %w(ticket_types topups refunds)
    v.each do |m|
      method("check_#{m}").call
    end
    @errors
  end

  def check_ticket_types
    company_codes = @event.company_ticket_types.map(&:company_code)
    credentials = @event.company_ticket_types.map(&:credential_type_id)
    @errors <<  error("company_codes") if company_codes.size != company_codes.reject(&:blank?).size
    @errors << error("credential_types") if credentials.size != credentials.compact.size
  end

  def check_topups
    @errors << error("topups") if @event.top_ups? && @event.payment_services.zero?
  end

  def check_refunds
    @errors << error("refunds") if @event.refunds? && @event.refund_services.zero?
  end

  private

  def error(err)
    I18n.t("errors.event_alerts.#{err}")
  end
end
