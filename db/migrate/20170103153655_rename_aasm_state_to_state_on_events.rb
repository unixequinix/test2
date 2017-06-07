class RenameAasmStateToStateOnEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :aasm_state, :state
  end
end
