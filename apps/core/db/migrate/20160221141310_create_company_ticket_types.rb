class CreateCompanyTicketTypes < ActiveRecord::Migration
  def change
    create_table :company_ticket_types do |t|
      t.references :event, null: false
      t.references :company_event_agreement, null: false
      t.references :credential_type, null: false
      t.string :name
      t.string :company_ticket_type_ref

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_index :company_ticket_types,
              [:company_ticket_type_ref, :company_event_agreement_id],
              unique: true, name: "company_ref_event_agreement_index"
  end
end
