class AddActionIndexOnTransactions < ActiveRecord::Migration[5.0]
  def change
    add_index(:transactions, :action, using: :btree) unless index_exists?(:transactions, :action, using: :btree)
  end
end
