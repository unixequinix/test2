class RemoveActiveFromTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :active, :boolean, default: true
  end
end
