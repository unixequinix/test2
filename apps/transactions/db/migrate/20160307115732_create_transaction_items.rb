class CreateTransactionItems < ActiveRecord::Migration
  def change
    create_table :sale_items do |t|
      t.integer :product_id, foreign_key: false
      t.integer :quantity
      t.float :amount
      t.references :credit_transaction
    end
  end
end
