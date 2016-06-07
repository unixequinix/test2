class Entitlement::PositionCreator < Entitlement::PositionManager
  def create_new_position
    return 1 if last_element.blank?
    last_element.memory_position + last_element.memory_length
  end
end
