class CreateCredentialTypes < ActiveRecord::Migration
  def change
    create_table :credential_types do |t|
      t.integer :position, null: false
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
