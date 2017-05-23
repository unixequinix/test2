class AddColumnConstraintsToDevices < ActiveRecord::Migration[5.1]
  def change
    DeviceRegistration.where(device: Device.where(mac: nil)).delete_all
    Device.where(mac: nil).delete_all
    change_column_null :devices, :mac, false
  end
end
