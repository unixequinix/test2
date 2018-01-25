class AddAmountToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :amount, :decimal, precision: 8, scale: 2, null: false, default: 0.00
  end
end
