class RemoveTagSerialNumerFromGtags < ActiveRecord::Migration
  def change
    remove_column :gtags, :tag_serial_number
  end
end
