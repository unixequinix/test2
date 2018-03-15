class AddIndexToTicketTypes < ActiveRecord::Migration[5.1]
  def change
    add_index :ticket_types, [:event_id, :company, :name], unique: true
  end
end
