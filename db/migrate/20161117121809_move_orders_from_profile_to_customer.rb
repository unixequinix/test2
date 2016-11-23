class MoveOrdersFromProfileToCustomer < ActiveRecord::Migration
  def change
    add_reference :orders, :customer, foreign_key: true, index: true

    sql = "UPDATE orders ORD
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = ORD.profile_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_reference :orders, :profile
  end
end
