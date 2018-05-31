class ReaddTransactionIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :transactions, %i[event_id device_id device_db_index device_created_at_fixed gtag_counter], name: "index_transactions_on_device_columns", unique: true
  end
end
