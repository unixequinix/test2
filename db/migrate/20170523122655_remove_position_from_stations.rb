class RemovePositionFromStations < ActiveRecord::Migration[5.1]
  def change
    remove_column :stations, :position, :integer
  end
end
