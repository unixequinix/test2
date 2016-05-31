class SortStations < ActiveRecord::Migration
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
