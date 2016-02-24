class RemveTypeFromTransactionParameters < ActiveRecord::Migration
  def change
    remove_column :transaction_parameters, :type, :string
  end
end
