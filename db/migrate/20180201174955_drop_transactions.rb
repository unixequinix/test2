class DropTransactions < ActiveRecord::Migration[5.1]
  def change
    drop_table :sale_items
    drop_table :transactions
  end
end
