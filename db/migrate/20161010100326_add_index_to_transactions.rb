class AddIndexToTransactions < ActiveRecord::Migration
  def change
    add_index(:transactions, :old_id)
  end
end
