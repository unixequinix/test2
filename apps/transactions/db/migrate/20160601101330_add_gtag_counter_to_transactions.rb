class AddGtagCounterToTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :gtag_counter, :integer
    add_column :access_transactions, :gtag_counter, :integer
    add_column :credential_transactions, :gtag_counter, :integer
    add_column :money_transactions, :gtag_counter, :integer
    add_column :order_transactions, :gtag_counter, :integer
    add_column :ban_transactions, :gtag_counter, :integer

    add_column :credit_transactions, :counter, :integer
    add_column :access_transactions, :counter, :integer
    add_column :credential_transactions, :counter, :integer
    add_column :money_transactions, :counter, :integer
    add_column :order_transactions, :counter, :integer
    add_column :ban_transactions, :counter, :integer
  end
end
