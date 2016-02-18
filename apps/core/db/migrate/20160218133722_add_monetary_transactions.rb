class AddMonetaryTransactions < ActiveRecord::Migration
  def change
    create_table :monetary_transactions do |t|
      t.references :transaction
      t.integer :credits
      t.integer :credits_refundable
      t.integer :value_credit
      t.string :payment_gateway
      t.string :payment_method
      t.integer :final_balance
      t.integer :final_refundable_balance
    end

    remove_column :transactions, :credits
    remove_column :transactions, :credits_refundable
    remove_column :transactions, :value_credit
    remove_column :transactions, :payment_gateway
    remove_column :transactions, :payment_method
    remove_column :transactions, :final_balance
    remove_column :transactions, :final_refundable_balance
  end
end
