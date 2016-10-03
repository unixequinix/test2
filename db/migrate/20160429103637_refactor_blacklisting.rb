class RefactorBlacklisting < ActiveRecord::Migration
  def change # rubocop:disable all
    add_column :tickets, :blacklist, :boolean, default: false
    add_column :gtags, :blacklist, :boolean, default: false
    add_column :customer_event_profiles, :blacklist, :boolean, default: false

    drop_table :banned_tickets do |t|
      t.references :ticket, null: false
      t.timestamps null: false
    end

    drop_table :banned_gtags do |t|
      t.references :gtag, null: false
      t.timestamps null: false
    end

    drop_table :banned_customer_event_profiles do |t|
      t.references :customer_event_profile, null: false
      t.timestamps null: false
    end

    create_table :blacklist_transactions do |t|
      t.references :event, index: true, foreign_key: true
      t.string :transaction_origin
      t.string :transaction_type
      t.references :station, index: true, foreign_key: true
      t.integer :customer_event_profile, index: true, foreign_key: true
      t.string :device_uid
      t.integer :device_db_index
      t.string :device_created_at
      t.string :customer_tag_uid
      t.string :operator_tag_uid
      t.references :blacklisted, polymorphic: true, null: false
      t.text :reason
      t.integer :status_code
      t.string :status_message
      t.timestamps null: false
    end
  end
end
