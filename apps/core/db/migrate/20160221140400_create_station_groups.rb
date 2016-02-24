class CreateStationGroups < ActiveRecord::Migration
  def change
    create_table :station_groups do |t|
      t.string :name, index: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
