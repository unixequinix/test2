class AddCreditsToOldOrders < ActiveRecord::Migration[5.1]
  def change
    orders = OrderItem.where(order: Order.completed).group(:order_id).count
    single_order_items = OrderItem.where(order_id: orders.select { |_, v| v == 1 }.keys)

    CatalogItem.where(id: single_order_items.select(:catalog_item_id).distinct.pluck(:catalog_item_id)).each do |item|
      single_order_items.where(catalog_item: item).group_by(&:amount).each do |amount, items|
        credits = item.credits * amount
        virtual_credits = item.virtual_credits * amount
        Order.where(id: items.map(&:order_id)).update_all(credits: credits, virtual_credits: virtual_credits)
      end
    end

    double_order_items = OrderItem.where(order_id: orders.select { |_, v| v > 1 }.keys)
    Order.where(id: double_order_items.select(:order_id).distinct.pluck(:order_id)).each do |order|
      order.update_columns(credits: order.order_items.sum(&:credits), virtual_credits: order.order_items.sum(&:virtual_credits))
    end
  end
end
