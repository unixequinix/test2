class UniteDevicesByMac < ActiveRecord::Migration[5.1]
  def change
    Device.all.order(:id).group_by { |device| device.asset_tracker&.downcase  }.select { |_, devices| devices.size > 1 }.each do |_, devices|
      Device.where(id: devices.map(&:id)).update_all asset_tracker: nil
    end

    Device.all.order(:id).group_by { |device| device.mac.downcase }.select { |_, devices| devices.size > 1 }.each do |_, devices|
      device = devices.last
      rest_of_devices = devices - [device]
      Poke.where(device: devices).update_all(device_id: device.id)
      DeviceRegistration.where(device: devices).update_all(device_id: device.id)
      DeviceTransaction.where(device: devices).update_all(device_id: device.id)
      rest_of_devices.map(&:delete)
      device.update!(mac: device.mac.downcase)
    end
  end
end
