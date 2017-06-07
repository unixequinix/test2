class DeviceCreator < ApplicationJob
  def perform(atts, asset_tracker)
    device = Device.find_or_create_by!(atts)
    device.update!(asset_tracker: asset_tracker)
  end
end
