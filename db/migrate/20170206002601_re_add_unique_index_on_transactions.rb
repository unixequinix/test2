class ReAddUniqueIndexOnTransactions < ActiveRecord::Migration[5.0]
  def change
    columns = [:event_id, :device_uid, :device_db_index, :device_created_at_fixed, :gtag_counter]
    add_index(:transactions, columns, name: :index_transactions_on_device_columns, unique: true, using: :btree) unless index_exists?(:transactions, columns, name: :index_transactions_on_device_columns, unique: true)
  end
end
