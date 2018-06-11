class RemoveRefundOrders < ActiveRecord::Migration[5.1]
  def change
    orders = Order.where.not(status: "completed")
    OrderItem.where(order: orders).delete_all
    Transaction.where(order: orders).delete_all
    orders.delete_all

    items = OrderItem.where("amount < 0")
    ids = items.pluck(:order_id)

    orders2 = Order.where(id: ids).where.not(gateway: "admin")
    OrderItem.where(order: orders2).delete_all
    Transaction.where(order: orders2).delete_all
    orders2.delete_all
  end
end
