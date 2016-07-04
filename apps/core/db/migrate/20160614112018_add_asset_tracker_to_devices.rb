class AddAssetTrackerToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :asset_tracker, :string
  end
end
