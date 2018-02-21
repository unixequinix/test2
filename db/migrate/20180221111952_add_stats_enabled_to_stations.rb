class AddStatsEnabledToStations < ActiveRecord::Migration[5.1]
  def change
    add_column :stations, :device_stats_enabled, :boolean, default: true
  end
end
