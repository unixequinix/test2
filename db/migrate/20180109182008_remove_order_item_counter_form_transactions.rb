class RemoveOrderItemCounterFormTransactions < ActiveRecord::Migration[5.1]
  def change
    remove_column :transactions, :order_item_counter, :integer
  end
end
