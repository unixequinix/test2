class AddPriceMoneyToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :price_money, :decimal,  precision: 8, scale: 2, default: "0.0", null: false
    change_column_default :refunds, :amount, "0.0"
  end
end
