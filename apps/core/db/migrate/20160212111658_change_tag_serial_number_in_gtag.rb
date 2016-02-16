class ChangeTagSerialNumberInGtag < ActiveRecord::Migration
  def change
    change_column :gtags, :tag_serial_number, :string, null: true
  end
end
