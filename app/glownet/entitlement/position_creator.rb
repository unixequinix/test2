class Entitlement::PositionCreator < Entitlement::PositionManager
  def create_new_position
    last_element.blank? ? 1 : last_element.memory_position + last_element.memory_length
  end
end
