class AddIndexToTransactions < ActiveRecord::Migration
  def change
    add_index :transactions, :type
    add_index :transactions, :profile_id
  end
end
