module Creators
  class DeviceJob < Base
    def perform(atts, asset_tracker)
      device = Device.find_or_create_by(mac: atts[:mac])
      device.update!(asset_tracker: asset_tracker)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
