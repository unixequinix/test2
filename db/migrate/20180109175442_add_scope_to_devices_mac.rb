class AddScopeToDevicesMac < ActiveRecord::Migration[5.1]
  def change
    remove_index :devices, :mac
    add_index :devices, [:mac, :team_id], unique: true
    add_index :devices, [:asset_tracker, :team_id], unique: true
  end
end
