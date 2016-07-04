class AddDatabaseToEvents < ActiveRecord::Migration
  def up
    add_attachment :events, :device_database
  end

  def down
    remove_attachment :events, :device_database
  end
end
