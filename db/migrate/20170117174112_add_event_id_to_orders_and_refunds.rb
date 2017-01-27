class AddEventIdToOrdersAndRefunds < ActiveRecord::Migration[5.0]
  def change
    add_reference :refunds, :event, foreign_key: true, index: true
    add_reference :orders, :event, foreign_key: true, index: true

    sql = "UPDATE refunds
          SET event_id = customers.event_id
          FROM customers
          WHERE refunds.customer_id = customers.id"
    Refund.find_by_sql(sql)

    sql = "UPDATE orders
          SET event_id = customers.event_id
          FROM customers
          WHERE orders.customer_id = customers.id"
    Order.find_by_sql(sql)
  end
end
