class CreateCompanyTicketTypes < ActiveRecord::Migration
  def change
    create_table :company_ticket_types do |t|
      t.integer :company_id
      t.integer :preevent_product_id
      t.integer :event_id
      t.string :name
      t.string :company_ticket_type_ref

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
