class RemoveGtagIndexOnTransactions < ActiveRecord::Migration[5.0]
  def change
    remove_index(:transactions, [:gtag_id, :type]) if index_exists?(:transactions, [:gtag_id, :type])
  end
end
