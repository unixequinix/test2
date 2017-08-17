class AddIndexesToStats < ActiveRecord::Migration[5.1]
  def change
    add_index(:stats, :event_id) unless index_exists?(:stats, :event_id)
    add_index(:stats, :device_id) unless index_exists?(:stats, :device_id)
    add_index(:stats, :station_id) unless index_exists?(:stats, :station_id)
  end
end
