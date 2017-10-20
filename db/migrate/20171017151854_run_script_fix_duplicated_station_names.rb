class RunScriptFixDuplicatedStationNames < ActiveRecord::Migration[5.1]
  def change
    Event.all.each do |event|
      event.stations.group(:name).count.select{ |_, count| count > 1 }.each do |name, _|
        stations = event.stations.where name: name

        stations.each.with_index do |station, index|
          station.update! name: "#{station.name} ##{index + 1}"
        end
      end
    end
  end
end
