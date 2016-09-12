class AddActivationCounterToTransactions < ActiveRecord::Migration
  def change
    add_column :access_transactions, :activation_counter, :integer
    add_column :credential_transactions, :activation_counter, :integer
    add_column :credit_transactions, :activation_counter, :integer
    add_column :money_transactions, :activation_counter, :integer
    add_column :order_transactions, :activation_counter, :integer
    add_column :ban_transactions, :activation_counter, :integer
  end
end
