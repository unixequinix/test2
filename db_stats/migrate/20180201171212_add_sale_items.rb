class AddSaleItems < ActiveRecord::Migration[5.1]
  def change
    create_table "sale_items" do |t|
      t.integer "quantity", null: false
      t.float "standard_unit_price"
      t.integer "credit_transaction_id", null: false
      t.bigint "product_id"
      t.string "sale_item_type"
      t.jsonb "payments", default: {}
      t.decimal "standard_total_price", precision: 10, scale: 2
      t.index :credit_transaction_id
      t.index :product_id
    end
  end
end
