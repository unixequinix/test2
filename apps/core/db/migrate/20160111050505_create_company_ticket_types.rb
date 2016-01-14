class CreateCompanyTicketTypes < ActiveRecord::Migration
  def change
    create_table :company_ticket_types do |t|
      t.integer :event_id
      t.string :name
      t.string :company

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
