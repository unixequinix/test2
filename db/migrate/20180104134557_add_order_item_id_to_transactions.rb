class AddOrderItemIdToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :order_item_id, :bigint
  end
end
