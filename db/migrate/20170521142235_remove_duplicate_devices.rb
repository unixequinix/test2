class RemoveDuplicateDevices < ActiveRecord::Migration[5.0]
  def change
    Device.group(:mac).count.each do |mac, count|
      next unless count > 1
      devices = Device.where(mac: mac).order(:asset_tracker).to_a
      good_one = devices.shift
      DeviceTransaction.where(device_id: devices.map(&:id)).update_all(device_id: good_one.id)
      DeviceRegistration.where(device_id: devices.map(&:id)).update_all(device_id: good_one.id)
      devices.map(&:destroy!)
    end
  end
end
