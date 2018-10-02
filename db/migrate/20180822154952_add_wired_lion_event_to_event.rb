class AddWiredLionEventToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :wiredlion_event, :string
  end
end
