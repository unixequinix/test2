class CreateTransactionItems < ActiveRecord::Migration
  def change
    create_table :sale_items do |t|
      t.integer :catalogable_id, foreign_key: false
      t.string :catalogable_type
      t.integer :quantity
      t.float :amount
      t.references :credit_transaction
    end
  end
end
