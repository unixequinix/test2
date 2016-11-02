class EditAccessTransaction < ActiveRecord::Migration
  def change
    remove_index :access_transactions, name: "index_access_transactions_on_device_id"
    remove_column :access_transactions, :device_id
    add_column :access_transactions, :device_uid, :string
  end
end
