class AddCurrentTimeToDeviceRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_column :device_registrations, :current_time, :datetime
  end
end
