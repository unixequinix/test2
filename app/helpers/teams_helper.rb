module TeamsHelper
  def devices_counter(used, total)
    "#{used} - #{device_counter_percentage(used, total)}"
  end

  def device_counter_percentage(used, total)
    "#{(used.to_f / total.to_f).round(2) * 100} %"
  end

  def device_owner?(user, device)
    user&.team == device&.team
  end
end
