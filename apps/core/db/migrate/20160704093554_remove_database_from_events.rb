class RemoveDatabaseFromEvents < ActiveRecord::Migration
  def up
    remove_attachment :events, :device_database
  end

  def down
    add_attachment :events, :device_database
  end
end
