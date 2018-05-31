class AddEmvPos < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :emv_enabled, :emv_topup_enabled
    add_column :events, :emv_pos_enabled, :boolean, default: false
  end
end
