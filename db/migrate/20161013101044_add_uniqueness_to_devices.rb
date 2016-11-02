class AddUniquenessToDevices < ActiveRecord::Migration
  def change
    Device.all.group_by { |d| [d.mac, d.serial_number, d.imei] }.each do |_, devices|
      devices.drop(1).map(&:destroy)
    end
    add_index :devices, [:mac, :imei, :serial_number], unique: true
  end
end
