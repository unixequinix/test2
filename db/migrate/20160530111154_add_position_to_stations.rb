class AddPositionToStations < ActiveRecord::Migration
  def change
    add_column :stations, :position, :integer
  end
end
