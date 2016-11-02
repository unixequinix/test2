class CreateEntitlements < ActiveRecord::Migration
  def change
    create_table :entitlements do |t|
      t.references :entitlementable, polymorphic: true, null: false
      t.references :event, null: false
      t.integer :memory_position, null: false
      t.string :memory_length, null: false, default: :simple
      t.boolean :infinite, null: false, default: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
