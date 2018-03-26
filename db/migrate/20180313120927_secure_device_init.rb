class SecureDeviceInit < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :app_id, :string
    add_column :devices, :imei, :string
    add_column :devices, :manufacturer, :string
    add_column :devices, :device_model, :string
    add_column :devices, :android_version, :string
    add_column :devices, :extra_info, :jsonb, default: {}

    add_index :devices, :app_id, unique: true

    remove_index :devices, [:mac, :team_id]
    remove_index :devices, [:asset_tracker, :team_id]

    change_column_null :devices, :mac, true

    add_column :transactions, :device_id, :integer
    add_index :transactions, :device_id
  end
end
