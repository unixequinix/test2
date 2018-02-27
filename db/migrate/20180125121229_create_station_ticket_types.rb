class CreateStationTicketTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :station_ticket_types do |t|
      t.references :station, foreign_key: true
      t.references :ticket_type, foreign_key: true

      t.timestamps
    end
  end
end
