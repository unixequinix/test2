class EventValidator
  attr_reader :errors

  def initialize(event)
    @event = event
    @errors = []
  end

  def all
    ticket_types = @event.ticket_types
    @errors << error("company_codes") if ticket_types.map(&:company_code).any?(&:blank?)
    @errors << error("catalog_items") if ticket_types.map(&:catalog_item_id).any?(&:blank?)
  end

  private

  def error(err)
    I18n.t("errors.event_alerts.#{err}")
  end
end
