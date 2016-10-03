class AddOfficialNameToStations < ActiveRecord::Migration
  def change
    add_column :stations, :official_name, :string
  end
end
