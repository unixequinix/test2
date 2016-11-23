class RemoveCustomerOrders < ActiveRecord::Migration
  def change
    drop_table :customer_orders
    add_column :order_items, :redeemed, :boolean
    add_column :order_items, :counter, :integer
  end
end
