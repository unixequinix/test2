class AddPriorityToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :priority, :integer
    rename_column :transactions, :reason, :message
  end
end
