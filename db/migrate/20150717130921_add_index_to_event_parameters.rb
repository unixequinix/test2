class AddIndexToEventParameters < ActiveRecord::Migration
  def change
    add_index :event_parameters, [:event_id, :parameter_id], unique: true
  end
end