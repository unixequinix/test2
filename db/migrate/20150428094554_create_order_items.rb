class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :order, null: false
      t.belongs_to :online_product, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.decimal :total, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end
