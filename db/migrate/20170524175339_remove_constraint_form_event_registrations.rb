class RemoveConstraintFormEventRegistrations < ActiveRecord::Migration[5.1]
  def change
    change_column_null :event_registrations, :user_id, true
  end
end
