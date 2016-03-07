class CreateTransactionItems < ActiveRecord::Migration
  def change
    create_table :transaction_items do |t|
      t.integer :catalogable_id, foreign_key: false
      t.string :catalogable_type
      t.integer :quantity
      t.float :amount
      t.references :credit_transaction
    end
  end
end
