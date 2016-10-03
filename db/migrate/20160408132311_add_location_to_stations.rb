class AddLocationToStations < ActiveRecord::Migration
  def change
    add_column :stations, :location, :string
  end
end
