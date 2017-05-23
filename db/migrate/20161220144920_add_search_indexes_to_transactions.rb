class AddSearchIndexesToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_index(:transactions, :device_uid, using: :btree) unless index_exists?(:transactions, :device_uid)
    add_index(:transactions, :device_db_index, using: :btree) unless index_exists?(:transactions, :device_db_index)
    add_index(:transactions, :device_created_at_fixed, using: :btree) unless index_exists?(:transactions, :device_created_at_fixed)
    add_index(:transactions, :gtag_counter, using: :btree) unless index_exists?(:transactions, :gtag_counter)
    add_index(:transactions, :activation_counter, using: :btree) unless index_exists?(:transactions, :activation_counter)
  end
end
