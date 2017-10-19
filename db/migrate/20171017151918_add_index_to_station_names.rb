class AddIndexToStationNames < ActiveRecord::Migration[5.1]
  def change
    add_index(:stations, %I[event_id name], unique: true)
  end
end
