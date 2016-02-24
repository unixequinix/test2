class CreateStationTypes < ActiveRecord::Migration
  def change
    create_table :station_types do |t|
      t.string :name, index: true, null: false
      t.references :station_group, null: false

      t.timestamps null: false
    end
  end
end
