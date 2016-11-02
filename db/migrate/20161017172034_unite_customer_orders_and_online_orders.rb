class UniteCustomerOrdersAndOnlineOrders < ActiveRecord::Migration
  def change
    add_column :customer_orders, :counter, :integer, default: 0
    add_column :customer_orders, :redeemed, :boolean, default: false

    sql = "UPDATE customer_orders CO
           SET counter = OO.counter,
               redeemed = OO.redeemed
           FROM online_orders OO
           WHERE  OO.customer_order_id = CO.id"

    ActiveRecord::Base.connection.execute(sql)

    drop_table :online_orders
  end
end
