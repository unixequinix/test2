class CreateCompanyEventAgreements < ActiveRecord::Migration
  def change
    create_table :company_event_agreements do |t|
      t.references :company, null: false
      t.references :event, null: false
      t.string :name

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
