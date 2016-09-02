class AddHiddenToStations < ActiveRecord::Migration
  def change
    add_column :stations, :hidden, :boolean
  end
end
