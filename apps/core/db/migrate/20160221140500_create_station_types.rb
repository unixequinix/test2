class CreateStationTypes < ActiveRecord::Migration
  def change
    create_table :station_types do |t|
      t.references :station_group, null: false
      t.string :name, index: true, null: false
      t.text :description

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
