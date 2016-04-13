class AddStatusCodeToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :status_code, :integer
    remove_column :order_transactions, :integer, :string
  end
end
