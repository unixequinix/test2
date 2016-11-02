class AddCountersToDeviceTransactions < ActiveRecord::Migration
  def change
    add_column :device_transactions, :gtag_counter, :integer, default: 0
    add_column :device_transactions, :counter, :integer, default: 0
  end
end
