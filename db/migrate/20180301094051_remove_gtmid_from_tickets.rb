class RemoveGtmidFromTickets < ActiveRecord::Migration[5.1]
  def change
    remove_column :tickets, :gtmid, :string, :null => true
  end
end
