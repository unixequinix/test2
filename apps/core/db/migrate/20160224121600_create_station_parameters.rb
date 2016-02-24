class CreateStationParameters < ActiveRecord::Migration
  def change
    create_table :station_parameters do |t|
      t.references :station, null: false
      t.references :station_parametable, polymorphic: true, null: false

      t.timestamps null: false
    end
  end
end
