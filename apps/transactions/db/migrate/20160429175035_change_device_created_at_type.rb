class ChangeDeviceCreatedAtType < ActiveRecord::Migration
  def change
    change_column :money_transactions, :device_created_at, :string
    change_column :order_transactions, :device_created_at, :string
    change_column :credit_transactions, :device_created_at, :string
    change_column :credential_transactions, :device_created_at, :string
    change_column :access_transactions, :device_created_at, :string
    change_column :blacklist_transactions, :device_created_at, :string
  end
end
