class CreateTicketBlacklists < ActiveRecord::Migration
  def change
    create_table :ticket_blacklists do |t|
      t.references :ticket, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
