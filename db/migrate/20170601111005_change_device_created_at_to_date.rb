class ChangeDeviceCreatedAtToDate < ActiveRecord::Migration[5.1]
  def change
    change_column :transactions, :device_created_at, 'varchar USING substring(device_created_at, 1, 19)'
  end
end
