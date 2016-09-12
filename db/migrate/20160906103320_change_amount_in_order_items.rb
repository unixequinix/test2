class ChangeAmountInOrderItems < ActiveRecord::Migration
  def change
    change_column :order_items, :amount, :float
  end
end
