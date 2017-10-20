class DivideOpenApiConfigInto3 < ActiveRecord::Migration[5.1]
  def change
    rename_column :events, :open_api, :open_devices_api
    add_column :events, :open_ticketing_api, :boolean, default: false
    add_column :events, :open_api, :boolean, default: false
  end
end
