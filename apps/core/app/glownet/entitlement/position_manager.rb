class Entitlement::PositionManager
  def initialize(entitlement)
    @entitlement = entitlement
    @position_creator = Entitlement::PositionCreator.new(@entitlement)
    @position_updater = Entitlement::PositionUpdater.new(@entitlement)
  end

  def start(params)
    send("#{params[:action]}_memory_position")
  end

  def save_memory_position
    if @entitlement.id.nil?
      @entitlement.memory_position = @position_creator.create_new_position
    else
      @position_updater.calculate_memory_position_after_update
    end
  end

  def destroy_memory_position
    @position_updater.calculate_memory_position_after_destroy
  end

  def validate_memory_position
    return if @entitlement.memory_position + @entitlement.memory_length <= limit
    errors[:memory_position] << I18n.t("errors.messages.not_enough_space_for_entitlement")
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
