class ChangesIndexInTickets < ActiveRecord::Migration
  def change
    remove_index :tickets, :code
    add_index :tickets, [:deleted_at, :code, :event_id], unique: true
  end
end
