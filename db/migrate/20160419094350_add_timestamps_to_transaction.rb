class AddTimestampsToTransaction < ActiveRecord::Migration
  def change
    change_table :money_transactions, &:timestamps
    change_table :credit_transactions, &:timestamps
    change_table :credential_transactions, &:timestamps
    change_table :order_transactions, &:timestamps
    change_table :access_transactions, &:timestamps
  end
end
