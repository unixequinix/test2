class MoveTicketsFromProfileToCustomer < ActiveRecord::Migration
  def change
    add_reference :tickets, :customer, foreign_key: true, index: true

    sql = "UPDATE tickets TCK
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = TCK.profile_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_reference :tickets, :profile
  end
end
