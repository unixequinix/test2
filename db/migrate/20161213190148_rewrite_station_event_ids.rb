class RewriteStationEventIds < ActiveRecord::Migration
  def change
    Event.all.each do |e|
      e.stations.each.with_index { |station, i| station.update station_event_id: i + 1 }
    end
  end
end