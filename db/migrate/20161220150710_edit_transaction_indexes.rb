class EditTransactionIndexes < ActiveRecord::Migration
  def change
    remove_index(:transactions, :device_uid) if index_exists?(:transactions, :device_uid)
    remove_index(:transactions, :device_db_index) if index_exists?(:transactions, :device_db_index)
    remove_index(:transactions, :device_created_at_fixed) if index_exists?(:transactions, :device_created_at_fixed)
    remove_index(:transactions, :gtag_counter) if index_exists?(:transactions, :gtag_counter)
    remove_index(:transactions, :activation_counter) if index_exists?(:transactions, :activation_counter)

    columns = [:event_id, :device_uid, :device_db_index, :device_created_at_fixed, :gtag_counter, :activation_counter]
    add_index(:transactions, columns, name: :index_transactions_on_device_columns, unique: true, using: :btree) unless index_exists?(:transactions, columns, name: :index_transactions_on_device_columns, unique: true)
  end
end
