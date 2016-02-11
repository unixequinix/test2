class DestroyTicketColumns < ActiveRecord::Migration
  def change
    remove_column :tickets, :purchaser_email
    remove_column :tickets, :purchaser_first_name
    remove_column :tickets, :purchaser_last_name
  end
end
