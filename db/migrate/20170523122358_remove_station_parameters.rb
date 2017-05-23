class RemoveStationParameters < ActiveRecord::Migration[5.1]
  def change
    drop_table :station_parameters if table_exists?(:station_parameters)
  end
end
