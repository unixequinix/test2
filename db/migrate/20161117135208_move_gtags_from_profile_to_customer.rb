class MoveGtagsFromProfileToCustomer < ActiveRecord::Migration
  def change
    add_reference :gtags, :customer, foreign_key: true, index: true

    sql = "UPDATE gtags GT
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = GT.profile_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_reference :gtags, :profile
  end
end
