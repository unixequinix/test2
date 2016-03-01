class CreateCredentialAssigments < ActiveRecord::Migration
  def change
    create_table :credential_assignments do |t|
      t.references :customer_event_profile
      t.references :credentiable, polymorphic: true, null: false
      t.string :aasm_state

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
