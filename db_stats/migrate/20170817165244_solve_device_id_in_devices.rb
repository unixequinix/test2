class SolveDeviceIdInDevices < ActiveRecord::Migration[5.1]
  def change
    remove_column(:stats, :device_uid, :citext) if column_exists?(:stats, :device_uid)
    add_column(:stats, :device_id, :integer) unless column_exists?(:stats, :device_id)
  end
end
