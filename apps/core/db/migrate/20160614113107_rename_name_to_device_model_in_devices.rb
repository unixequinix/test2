class RenameNameToDeviceModelInDevices < ActiveRecord::Migration
  def change
    rename_column :devices, :name, :device_model
  end
end
