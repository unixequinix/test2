class AddTicketingIntegrationIdToTicketTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :ticket_types, :ticketing_integration, foreign_key: true
  end
end
