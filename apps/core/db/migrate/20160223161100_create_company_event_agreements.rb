class CreateCompanyEventAgreements < ActiveRecord::Migration
  def change
    create_table :company_event_agreements do |t|
      t.integer :company_id, null: false, index: true
      t.integer :event_id, null: false, index: true
      t.string :name
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
