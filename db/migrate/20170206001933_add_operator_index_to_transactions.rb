class AddOperatorIndexToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_index :transactions, :operator_tag_uid
  end
end
