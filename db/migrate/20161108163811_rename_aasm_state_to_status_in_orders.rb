class RenameAasmStateToStatusInOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :aasm_state, :status
    remove_column :orders, :number
    change_column_default :orders, :status, "in_progress"
  end
end
