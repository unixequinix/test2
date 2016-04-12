class EditCtalogableInOrderTransactions < ActiveRecord::Migration
  def change
    remove_column :order_transactions, :catalog_item_id, :integer
    add_column :order_transactions, :catalogable_type, :string
    add_column :order_transactions, :catalogable_id, :integer
  end
end
