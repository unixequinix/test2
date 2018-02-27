class AddGtmIdToTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :gtmid, :string, :null => true
  end
end
