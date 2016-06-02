class SortStations < ActiveRecord::Migration
  class StationGroup < ActiveRecord::Base
    has_many :station_types
  end

  class StationType < ActiveRecord::Base
    belongs_to :station_group
    has_many :stations
  end

  class Station < ActiveRecord::Base
    belongs_to :station_type
  end

  def change
    add_column :stations, :group, :string
    add_column :stations, :category, :string

    Station.all.each do |s|
      type = s.station_type
      group = type.station_group
      s.update! group: group.name, category: type.name
    end

    remove_column :stations, :station_type_id, :integer

    drop_table :station_groups
    drop_table :station_types
  end
end
