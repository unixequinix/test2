class MoveRefundsFromProfileToCustomer < ActiveRecord::Migration
  def change
    add_reference :refunds, :customer, foreign_key: true, index: true

    sql = "UPDATE refunds RF
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = RF.profile_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_reference :refunds, :profile
  end
end
