class AddOperators < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :operator, :boolean, default: false
    add_column :transactions, :operator_id, :integer
    add_index :transactions, :operator_id
  end
end
