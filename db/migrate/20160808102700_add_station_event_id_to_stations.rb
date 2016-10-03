class AddStationEventIdToStations < ActiveRecord::Migration
  def change
    add_column :stations, :station_event_id, :integer

    Event.all.each do |event|
      event.stations.each_with_index do |station, index|
        station.update!(station_event_id: index + 1)
      end
    end
  end
end
