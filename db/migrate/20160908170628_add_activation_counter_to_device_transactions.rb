class AddActivationCounterToDeviceTransactions < ActiveRecord::Migration
  def change
    add_column :device_transactions, :activation_counter, :integer
  end
end
