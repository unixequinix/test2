class RemoveFieldsFromDevices < ActiveRecord::Migration[5.0]
  def change
    remove_column :devices, :imei, :string
    remove_column :devices, :serial_number, :string
    remove_column :devices, :device_model, :string
  end
end
