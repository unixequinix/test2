class CreateCompanyTicketTypes < ActiveRecord::Migration
  def change
    create_table :company_ticket_types do |t|
      t.references :event, null: false
      t.references :company_event_agreement, null: false
      t.references :credential_type
      t.string :name
      t.string :company_code

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_index :company_ticket_types,
              [:company_code, :company_event_agreement_id],
              unique: true, name: "company_ref_event_agreement_index"
  end
end
