class ChangeColumnsInGtags < ActiveRecord::Migration
  def change
    change_column :gtags, :tag_uid, :string, null: false
    change_column :gtags, :tag_serial_number, :string, null: false
    remove_index :gtags, column: :tag_uid
    add_index :gtags, [:tag_uid, :event_id], unique: true
  end
end
