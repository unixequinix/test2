class AddPreviousBalanceToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :previous_balance, :boolean, default: false
  end
end
