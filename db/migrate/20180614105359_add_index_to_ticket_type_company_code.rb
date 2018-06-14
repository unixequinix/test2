class AddIndexToTicketTypeCompanyCode < ActiveRecord::Migration[5.1]
  def change
    add_index :ticket_types, ["event_id", "company", "ticketing_integration_id", "company_code"], name: "index_ticket_types_on_integration_company_code", unique: true
  end
end
