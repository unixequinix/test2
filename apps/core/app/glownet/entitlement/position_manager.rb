class Entitlement::PositionManager
  def initialize(entitlement)
    @entitlement = entitlement
  end

  def last_position
    Entitlement.last_element.present? ?
      Entitlement.last_element.memory_position + Entitlement.last_element.memory_length :
      1
  end

  def last_element
    Entitlement.where(event_id: @entitlement.event_id).order("memory_position DESC").first
  end

  def limit
    Gtag.field_by_name(name: gtag_type, field: :entitlement_limit)
  end

  def gtag_type
    @entitlement.event.get_parameter("gtag", "form", "gtag_type")
  end
end