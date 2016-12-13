class AddMessageToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :message, :string unless column_exists?(:transactions, :message)
  end
end
