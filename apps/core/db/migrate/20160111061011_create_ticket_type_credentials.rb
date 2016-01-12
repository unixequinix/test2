class CreateTicketTypeCredentials < ActiveRecord::Migration
  def change
    create_table :ticket_type_credentials do |t|
      t.integer :companies_ticket_type_id
      t.integer :preevent_product_id

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
