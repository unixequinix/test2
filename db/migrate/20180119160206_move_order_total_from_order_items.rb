class MoveOrderTotalFromOrderItems < ActiveRecord::Migration[5.1]
  def change
    Order.select(:id).find_in_batches(batch_size: 50000).with_index do |orders, batch|
      puts " - Processing orders from #{batch  * 50000} to #{(batch + 1) * 50000}"
      OrderItem.where(order: orders).group(:order_id).sum(:total).each do |order_id, sum|
        Order.find(order_id).update_column :amount, sum
      end
    end
  end
end
