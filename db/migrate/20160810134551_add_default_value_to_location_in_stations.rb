class AddDefaultValueToLocationInStations < ActiveRecord::Migration
  def change
    change_column :stations, :location, :string, default: ""
  end
end
