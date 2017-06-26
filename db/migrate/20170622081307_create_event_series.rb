class CreateEventSeries < ActiveRecord::Migration[5.1]
  def change
    create_table :event_series do |t|
      t.string :name
      t.timestamps
    end
  end
end
