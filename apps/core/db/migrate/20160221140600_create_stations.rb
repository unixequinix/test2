class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.references :event, null: false
      t.references :station_type, null: false
      t.string :name, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end

