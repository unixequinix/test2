class RenameAasmStateToStateOnEvents < ActiveRecord::Migration
  def change
    rename_column :events, :aasm_state, :state
  end
end
