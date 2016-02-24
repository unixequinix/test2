class CreateCompanyTicketTypes < ActiveRecord::Migration
  def change
    create_table :company_ticket_types do |t|
      t.references :event
      t.references :company_event_agreement
      t.string :name
      t.string :company_ticket_type_ref

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
