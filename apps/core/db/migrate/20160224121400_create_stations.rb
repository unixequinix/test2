class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :name, null: false
      t.references :event, null: false
      t.references :station_type, null: false

      t.timestamps null: false
    end
  end
end
