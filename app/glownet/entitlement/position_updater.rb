class Entitlement::PositionUpdater < Entitlement::PositionManager
  def calculate_memory_position_after_update
    return change_memory_position(step) if (last_element&.memory_position).to_i + step <= limit
    @entitlement.errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
  end

  def calculate_memory_position_after_destroy
    change_memory_position(-@entitlement.memory_length)
  end

  def change_memory_position(step)
    Entitlement.where(event_id: @entitlement.event_id)
               .where("memory_position > ?", @entitlement.memory_position)
               .each { |entitlement| entitlement.increment!(:memory_position, step) }
  end

  private

  def step
    @entitlement.memory_length - previous_length
  end

  def previous_length
    Entitlement.find(@entitlement.id).memory_length
  end
end