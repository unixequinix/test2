class AddEventIndexToStats < ActiveRecord::Migration[5.1]
  def change
    add_index :stats, :station_id
    add_index :stats, :event_id
    add_index :stats, :customer_id
  end
end
