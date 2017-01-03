class AddIndexToGtagUid < ActiveRecord::Migration[5.0]
  def change
    to_delete = Gtag.select([:event_id, :tag_uid, :activation_counter]).group(:event_id, :tag_uid, :activation_counter).having("count(*) > 1")
    puts to_delete.pluck(:event_id).inspect
    add_index :gtags, [:event_id, :tag_uid, :activation_counter], unique: true
  end
end
