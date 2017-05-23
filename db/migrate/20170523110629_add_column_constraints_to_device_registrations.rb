class AddColumnConstraintsToDeviceRegistrations < ActiveRecord::Migration[5.1]
  def change
    change_column_null :device_registrations, :number_of_transactions, false
    change_column_null :device_registrations, :server_transactions, false
    change_column_null :device_registrations, :battery, false
    DeviceRegistration.where(server_transactions: nil).update_all(server_transactions: 0)
    DeviceRegistration.where(number_of_transactions: nil).update_all(number_of_transactions: 0)
    DeviceRegistration.where(battery: nil).update_all(battery: 0)
  end
end
