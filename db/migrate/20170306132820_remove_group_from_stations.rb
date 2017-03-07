class RemoveGroupFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :group, :string
  end
end
