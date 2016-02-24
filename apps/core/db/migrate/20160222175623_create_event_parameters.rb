class CreateEventParameters < ActiveRecord::Migration
  def change
    create_table :event_parameters do |t|
      t.string :value, default: "", null: false
      t.references :event
      t.references :parameter

      t.timestamps null: false
    end
    add_index :event_parameters, [:event_id, :parameter_id], unique: true
  end
end