class CreateGtags < ActiveRecord::Migration
  def change
    create_table :gtags do |t|
      t.references :event, null: false
      t.references :company_ticket_type
      t.string :tag_serial_number
      t.string :tag_uid, null: false
      t.boolean :credential_redeemed, default: false, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_index :gtags, [:tag_uid, :event_id], unique: true
  end
end
