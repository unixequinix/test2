class CreateEntitlements < ActiveRecord::Migration
  def change
    create_table :entitlements do |t|
      t.references :entitlementable, polymorphic: true, null: false
      t.integer :memory_position
      t.boolean :unlimited

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
