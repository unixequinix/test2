class RemoveActivationCounter < ActiveRecord::Migration[5.0]
  def change
    remove_column :gtags, :activation_counter, :integer
    remove_column :transactions, :activation_counter, :integer
    remove_column :transactions, :operator_activation_counter, :integer
  end
end
