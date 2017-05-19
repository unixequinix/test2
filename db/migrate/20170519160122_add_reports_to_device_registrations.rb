class AddReportsToDeviceRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :device_registrations, :battery, :integer, default: 0
    add_column :device_registrations, :number_of_transactions, :integer, default: 0
    add_column :device_registrations, :server_transactions, :integer, default: 0
    add_column :device_registrations, :action, :string
    add_index :transactions, :device_uid

    DeviceTransaction.where(battery: nil).update_all(battery: 0)
    DeviceTransaction.where(number_of_transactions: nil).update_all(number_of_transactions: 0)

    DeviceRegistration.all.each do |registration|
      event = registration.event
      t = event.device_transactions.where(device_uid: registration.device.mac).order(:counter).last
      registration.update(battery: t.battery,
                          number_of_transactions: t.number_of_transactions,
                          server_transactions: event.transactions.where(device_uid: t.device_uid).count,
                          action: t.action) if t
    end

    DeviceTransaction.where(action: ["device_report", "DEVICE_REPORT"]).destroy_all
  end
end
