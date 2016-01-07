class CreatePreeventProductCombos < ActiveRecord::Migration
  def change
    create_table :preevent_product_combos do |t|
      t.integer :preevent_product_unit_id
      t.integer :preevent_product_id
      t.integer :amount

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
