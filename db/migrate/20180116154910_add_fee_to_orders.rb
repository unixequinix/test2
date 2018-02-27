class AddFeeToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :fee, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
