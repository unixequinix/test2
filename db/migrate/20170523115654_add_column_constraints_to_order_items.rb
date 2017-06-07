class AddColumnConstraintsToOrderItems < ActiveRecord::Migration[5.1]
  def change
    OrderItem.where(amount: nil).update_all(amount: 0)
    OrderItem.where(counter: nil).update_all(counter: 0)

    change_column_null :order_items, :amount, false
    change_column_null :order_items, :counter, false

    change_column_default :order_items, :counter, 0
    change_column_default :order_items, :amount, 0
    change_column_default :order_items, :total, 0
  end
end
