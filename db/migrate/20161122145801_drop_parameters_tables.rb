class DropParametersTables < ActiveRecord::Migration
  def change
    drop_table :parameters
    drop_table :event_parameters
  end
end
