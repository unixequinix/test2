class AddIndexToTicketCodesWithinEvent < ActiveRecord::Migration[5.0]
  def change
    add_index :tickets, [:event_id, :code], unique: true
  end
end
