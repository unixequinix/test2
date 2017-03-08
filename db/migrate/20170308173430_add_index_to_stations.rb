class AddIndexToStations < ActiveRecord::Migration[5.0]
  def change
    Event.all.each do |event|
      event.stations.map.with_index { |station, i| station.update_column :station_event_id, i + 1 }
    end

    add_index :stations, [:station_event_id, :event_id], unique: true
    change_column :stations, :station_event_id, :integer, null: false
  end
end
