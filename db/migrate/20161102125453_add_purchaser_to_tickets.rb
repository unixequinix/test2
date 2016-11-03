class AddPurchaserToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :purchaser_first_name, :string
    add_column :tickets, :purchaser_last_name, :string
    add_column :tickets, :purchaser_email, :string

    sql = "UPDATE tickets CO
           SET purchaser_first_name = OO.first_name,
               purchaser_last_name = OO.last_name,
               purchaser_email = OO.email
           FROM purchasers OO
           WHERE OO.credentiable_id = CO.id
           AND OO.credentiable_type = 'Ticket'"

    ActiveRecord::Base.connection.execute(sql)

    drop_table :purchasers
  end
end
