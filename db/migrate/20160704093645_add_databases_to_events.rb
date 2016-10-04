class AddDatabasesToEvents < ActiveRecord::Migration
  def up
    add_attachment :events, :device_full_db
    add_attachment :events, :device_basic_db
  end

  def down
    remove_attachment :events, :device_full_db
    remove_attachment :events, :device_basic_db
  end
end
