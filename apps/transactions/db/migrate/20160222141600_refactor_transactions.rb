class RefactorTransactions < ActiveRecord::Migration
  def change
    remove_reference :access_transactions, :device
    remove_reference :credential_transactions, :device
    remove_reference :monetary_transactions, :device

    rename_column :access_transactions, :device_uid, :device_db_index
    rename_column :credential_transactions, :device_uid, :device_db_index
    rename_column :monetary_transactions, :device_uid, :device_db_index

    add_column :access_transactions, :device_uid, :string
    add_column :credential_transactions, :device_uid, :string
    add_column :monetary_transactions, :device_uid, :string

    drop_table :devices
  end
end
