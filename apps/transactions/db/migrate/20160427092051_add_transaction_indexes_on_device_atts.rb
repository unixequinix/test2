class AddTransactionIndexesOnDeviceAtts < ActiveRecord::Migration
  def change
    add_index :credit_transactions,
              [:event_id, :device_uid, :device_db_index, :device_created_at],
              unique: true,
              name: "credit_transaction_uniqueness_on_device"

    add_index :access_transactions,
              [:event_id, :device_uid, :device_db_index, :device_created_at],
              unique: true,
              name: "access_transaction_uniqueness_on_device"

    add_index :credential_transactions,
              [:event_id, :device_uid, :device_db_index, :device_created_at],
              unique: true,
              name: "credential_transaction_uniqueness_on_device"

    add_index :money_transactions,
              [:event_id, :device_uid, :device_db_index, :device_created_at],
              unique: true,
              name: "money_transaction_uniqueness_on_device"

    add_index :order_transactions,
              [:event_id, :device_uid, :device_db_index, :device_created_at],
              unique: true,
              name: "order_transaction_uniqueness_on_device"
  end
end
