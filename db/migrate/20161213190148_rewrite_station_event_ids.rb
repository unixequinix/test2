class RewriteStationEventIds < ActiveRecord::Migration
  def change
    Event.all.each do |e|
      Station.where(event_id: e.id).each.with_index { |station, i| station.update station_event_id: i + 1 }
    end
  end
end

