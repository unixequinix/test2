class AddDeviceTransactions < ActiveRecord::Migration
  def change
    create_table :device_transactions do |t|
      t.references  :event, index: true, foreign_key: true
      t.string   :action
      t.string   :device_uid
      t.integer  :device_db_index
      t.string   :device_created_at
      t.string   :device_created_at_fixed
      t.string   :initialization_type
      t.integer  :number_of_transactions

      t.timestamps
    end

    sql = " INSERT INTO device_transactions (event_id, action, device_uid, device_db_index, device_created_at, device_created_at_fixed, initialization_type, number_of_transactions)
            SELECT event_id, action, device_uid, device_db_index, device_created_at, device_created_at_fixed, initialization_type, number_of_transactions
            FROM transactions TS
            WHERE TS.type = 'DeviceTransaction';"

    ActiveRecord::Base.connection.execute(sql)

    ActiveRecord::Base.connection.execute("DELETE FROM transactions WHERE type = 'DeviceTransaction'")
    remove_column :transactions, :initialization_type
    remove_column :transactions, :number_of_transactions
  end
end
