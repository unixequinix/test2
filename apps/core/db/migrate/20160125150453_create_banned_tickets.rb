class CreateBannedTickets < ActiveRecord::Migration
  def change
    create_table :banned_tickets do |t|
      t.references :ticket, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
