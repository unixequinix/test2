class AddTimestampsToDeviceRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :device_registrations, :created_at, :datetime
    add_column :device_registrations, :updated_at, :datetime

    DeviceRegistration.update_all(created_at: Time.now, updated_at: Time.now)
  end
end
