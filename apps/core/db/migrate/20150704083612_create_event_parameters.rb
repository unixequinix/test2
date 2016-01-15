class CreateEventParameters < ActiveRecord::Migration
  def change
    create_table :event_parameters do |t|
      t.string :value, null: false, default: ''

      t.belongs_to :event, index: true, null: false
      t.belongs_to :parameter, index: true, null: false

      t.timestamps null: false
    end
  end
end
