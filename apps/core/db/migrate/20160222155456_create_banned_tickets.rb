class CreateBannedTickets < ActiveRecord::Migration
  def change
    create_table :banned_tickets do |t|
      t.references :ticket, null: false
      t.timestamps null: false

      t.datetime :deleted_at, index: true
    end
  end
end