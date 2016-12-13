class AddSettingsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :gtag_settings, :json
    add_column :events, :device_settings, :json
  end
end
