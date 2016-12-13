class RewriteOrderItemCounter < ActiveRecord::Migration
  def change
    OrderItem.all.select(:id, :order_id).includes(:order).group_by{ |oi| oi.order.customer_id }.each_pair do |_, order_items|
      order_items.each.with_index { |oi, i| oi.update counter: i + 1}
    end
    orders = Order.where(customer_id: nil)
    OrderItem.where(order: orders).delete_all
    orders.delete_all
  end
end
