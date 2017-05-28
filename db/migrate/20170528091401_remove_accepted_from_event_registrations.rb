class RemoveAcceptedFromEventRegistrations < ActiveRecord::Migration[5.1]
  def change
    remove_column :event_registrations, :accepted, :boolean
  end
end
