class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    add_index :gtags, [:event_id, :tag_uid], unique: true
  end
end
