class RenameCustomerOrderIdToOrderItemCounterInTransactions < ActiveRecord::Migration
  def change
    rename_column :transactions, :customer_order_id, :order_item_counter
  end
end
