class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :event, null: false
      t.references :company_ticket_type, null: false
      t.string :code, index: true, unique: true
      t.boolean :credential_redeemed, default: false, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end