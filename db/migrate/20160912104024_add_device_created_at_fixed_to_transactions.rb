class AddDeviceCreatedAtFixedToTransactions < ActiveRecord::Migration
  def change
    add_column :access_transactions, :device_created_at_fixed, :string
    add_column :credential_transactions, :device_created_at_fixed, :string
    add_column :credit_transactions, :device_created_at_fixed, :string
    add_column :money_transactions, :device_created_at_fixed, :string
    add_column :order_transactions, :device_created_at_fixed, :string
    add_column :ban_transactions, :device_created_at_fixed, :string
  end
end
