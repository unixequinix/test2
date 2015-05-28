class AddPurchaserToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :purchaser_email, :string
    add_column :tickets, :purchaser_name, :string
    add_column :tickets, :purchaser_surname, :string
  end
end
