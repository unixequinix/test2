class AddCreditsToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :credits, :decimal, precision: 8, scale: 2, default: "0.0", null: false
    add_column :orders, :virtual_credits, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
