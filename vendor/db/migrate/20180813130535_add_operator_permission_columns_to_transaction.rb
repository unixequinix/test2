class AddOperatorPermissionColumnsToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :role, :string, allow_nil: true
    add_column :transactions, :group, :string, allow_nil: true
    add_column :transactions, :station_permission_id, :integer, allow_nil: true
  end
end
