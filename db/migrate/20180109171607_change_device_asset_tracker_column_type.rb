class ChangeDeviceAssetTrackerColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :devices, :asset_tracker, :citext, from: :string
  end
end
