class AddIndexToTransactionsForBalanceUpdater < ActiveRecord::Migration[5.0]
  def change
    add_index(:transactions, [:gtag_id, :type], using: :btree)
  end
end
