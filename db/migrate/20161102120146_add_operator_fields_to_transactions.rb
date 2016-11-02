class AddOperatorFieldsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :operator_value, :string
    add_column :transactions, :operator_station_id, :integer
  end
end
