class AddIndexToGtags < ActiveRecord::Migration
  def change
    add_index :gtags, :tag_uid, unique: true
  end
end
