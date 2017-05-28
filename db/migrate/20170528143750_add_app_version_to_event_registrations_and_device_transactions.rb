class AddAppVersionToEventRegistrationsAndDeviceTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :device_registrations, :app_version, :string
    add_column :device_transactions, :app_version, :string
  end
end
