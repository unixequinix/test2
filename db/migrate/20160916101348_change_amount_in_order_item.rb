class ChangeAmountInOrderItem < ActiveRecord::Migration
  def change
    change_column :order_items, :amount, :decimal, precision: 8, scale: 2
  end
end
