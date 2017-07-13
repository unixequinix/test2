class CreateStats < ActiveRecord::Migration[5.1]
  def change
    create_table :stats do |t|
      t.integer :transaction_id, null: false
      t.integer :transaction_counter, null: false
      t.string :source, null: false
      t.integer :event_id, null: false
      t.string :event_name, null: false
      t.string :credit_name, null: false
      t.decimal :credit_value, precision: 8, scale: 2, null: false
      t.string :action, null: false
      t.integer :station_id, null: false
      t.string :station_name, null: false
      t.string :station_category
      t.integer :product_qty
      t.integer :product_id
      t.string :product_name
      t.string :date, null: false
      t.decimal :total, precision: 8, scale: 2, null: false
      t.string :payment_method, null: false
    end

    add_index(:stats, %i[transaction_id transaction_counter], unique: true, using: :btree)
  end
end
