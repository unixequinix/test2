class AddOperatorActivationCounterToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :operator_activation_counter, :integer
  end
end
