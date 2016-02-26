class CreateEntitlements < ActiveRecord::Migration
  def change
    create_table :entitlements do |t|
      t.references :entitlementable, polymorphic: true, null: false
      t.integer :memory_position, null: false
      t.string :type, null: false, default: :simple
      t.boolean :unlimited, null: false, default: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
