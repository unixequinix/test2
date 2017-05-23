class AddSearchIndexesToGtags < ActiveRecord::Migration[5.0]
  def change
    add_index(:gtags, :activation_counter, using: :btree) unless index_exists?(:gtags, :activation_counter)
    add_index(:gtags, :tag_uid, using: :btree) unless index_exists?(:gtags, :tag_uid)
  end
end
