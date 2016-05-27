class Entitlement::PositionCreator < Entitlement::PositionManager
  def last_element
    Entitlement.where(event_id: @entitlement.event_id).order("memory_position DESC").first
  end

  def create_new_position
    last_element.present? ?
      last_element.memory_position + last_element.memory_length :
      1
  end
end