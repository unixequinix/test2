class AddMonetaryToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :credits, :integer
    add_column :transactions, :credits_refundable, :integer
    add_column :transactions, :value_credit, :integer
    add_column :transactions, :payment_gateway, :string
    add_column :transactions, :final_balance, :integer
    add_column :transactions, :final_refundable_balance, :integer
    remove_column :transactions, :amount, :float
  end
end
