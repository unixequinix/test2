class RenamePalco4ToStubhub < ActiveRecord::Migration[5.1]
  def change
    TicketType.where(company: "Palco4").update_all(company: "Stubhub")
    ActiveRecord::Base.connection.execute("UPDATE ticketing_integrations SET type = 'TicketingIntegrationStubhub' WHERE type = 'TicketingIntegrationPalco4'")
  end
end
