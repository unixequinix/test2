class ReaddTicketTypeIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :ticket_types, ["event_id", "company", "name"]
    add_index :ticket_types, ["event_id", "company", "ticketing_integration_id", "name"], name: "index_ticket_types_on_integration", unique: true
  end
end
